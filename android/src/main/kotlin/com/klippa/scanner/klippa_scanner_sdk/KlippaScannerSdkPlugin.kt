package com.klippa.scanner.klippa_scanner_sdk


import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.Image
import android.util.Log
import android.util.Size
import androidx.annotation.NonNull
import com.klippa.scanner.KlippaScannerBuilder
import com.klippa.scanner.KlippaScannerListener
import com.klippa.scanner.model.KlippaImage
import com.klippa.scanner.model.KlippaImageColor
import com.klippa.scanner.model.KlippaScannerResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** KlippaScannerSdkPlugin */
class KlippaScannerSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var activityPluginBinding : ActivityPluginBinding? = null

  val listener = object : KlippaScannerListener {

    override fun klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
      val images: MutableList<Map<String, String>> = mutableListOf()

      for (image in result.images) {
        val imageDict = mapOf("Filepath" to image.location)
        images.add(imageDict)
      }

      val multipleDocuments: Boolean = result.multipleDocumentsModeEnabled
      val cropEnabled: Boolean = result.cropEnabled
      val timerEnabled: Boolean = result.timerEnabled

      val resultDict = mapOf(
        "Images" to images,
        "MultipleDocuments" to multipleDocuments,
        "Crop" to cropEnabled,
        "TimerEnabled" to timerEnabled)

      resultHandler?.success(resultDict)
      resultHandler = null
    }

    override fun klippaScannerDidFailWithException(exception: Exception) {
      resultHandler?.error(E_CANCELED, "Scanner was canceled with error: $exception", null)
    }

    override fun klippaScannerDidCancel() {
        resultHandler?.error(E_CANCELED, "Scanner was canceled", null)
    }

  }

  private val SESSION_REQUEST_CODE = 9293
  private val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
  private val E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
  private val E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
  private val E_CANCELED = "E_CANCELED"
  private val E_UNKNOWN_ERROR = "E_UNKNOWN_ERROR"
  private var resultHandler : Result? = null

  private lateinit var context: Context
  private lateinit var activity: Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "klippa_scanner_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.activityPluginBinding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.activityPluginBinding = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.activityPluginBinding = binding
  }

  override fun onDetachedFromActivity() {
    this.activityPluginBinding = null
  }



  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "startSession") {
      startSession(call, result)
    } else {
      result.notImplemented()
    }
  }

  private fun startSession(@NonNull call: MethodCall, @NonNull result: Result) {
    if (activityPluginBinding == null) {
      result.error(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist", null)
      return
    }

    try {
      if (!call.hasArgument("License")) {
        result.error(E_MISSING_SESSION_TOKEN, "Missing license", null)
        return
      }

      val builder = KlippaScannerBuilder(listener, call.argument<String>("License")!!)

      if (call.hasArgument("AllowMultipleDocuments")) {
        builder.menu.allowMultiDocumentsMode = call.argument<Boolean>("AllowMultipleDocuments")!!
      }

      if (call.hasArgument("DefaultMultipleDocuments")) {
        builder.menu.isMultiDocumentsModeEnabled = call.argument<Boolean>("DefaultMultipleDocuments")!!
      }

      if (call.hasArgument("DefaultCrop")) {
        builder.menu.isCropEnabled = call.argument<Boolean>("DefaultCrop")!!
      }

      if (call.hasArgument("MoveCloserMessage")) {
        builder.messages.moveCloserMessage = call.argument<String>("MoveCloserMessage")!!
      }

      if (call.hasArgument("ImageMaxWidth")) {
        builder.imageAttributes.resolutionMaxWidth = call.argument<Int>("ImageMaxWidth")!!
      }

      if (call.hasArgument("ImageMaxHeight")) {
        builder.imageAttributes.resolutionMaxWidth = call.argument<Int>("ImageMaxHeight")!!
      }

      if (call.hasArgument("ImageMaxQuality")) {
        builder.imageAttributes.outputQuality = call.argument<Int>("ImageMaxQuality")!!
      }

      if (call.hasArgument("PreviewDuration")) {
        builder.durations.previewDuration = call.argument<Double>("PreviewDuration")!!
      }

      if (call.hasArgument("Model.fileName")) {
        builder.objectDetectionModel?.modelName = call.argument<String>("Model.fileName")!!
      }

      if (call.hasArgument("Model.modelLabels")) {
        builder.objectDetectionModel?.modelLabels = call.argument<String>("Model.modelLabels")!!
      }

      if (call.hasArgument("Timer.allowed")) {
        builder.menu.allowTimer = call.argument<Boolean>("Timer.allowed")!!
      }

      if (call.hasArgument("Timer.enabled")) {
        builder.menu.isTimerEnabled = call.argument<Boolean>("Timer.enabled")!!
      }

      if (call.hasArgument("Timer.duration")) {
        builder.durations.timerDuration = call.argument<Double>("Timer.duration")!!
      }

      var height: Int = 0
      var width: Int = 0

      if (call.hasArgument("CropPadding.height")) {
        height = call.argument<Int>("CropPadding.height")!!
      }

      if (call.hasArgument("CropPadding.width")) {
        width = call.argument<Int>("CropPadding.width")!!
      }

      builder.imageAttributes.cropPadding = Size(width, height)

      if (call.hasArgument("Success.previewDuration")) {
        builder.durations.successPreviewDuration = call.argument<Double>("Success.previewDuration")!!
      }

      if (call.hasArgument("Success.message")) {
        builder.messages.successMessage = call.argument<String>("Success.message")!!
      }

      if (call.hasArgument("ShutterButton.allowshutterButton")) {
        builder.shutterButton.allowShutterButton = call.argument<Boolean>("ShutterButton.allowshutterButton")!!
      }

      if (call.hasArgument("ShutterButton.hideShutterButton")) {
        builder.shutterButton.hideShutterButton = call.argument<Boolean>("ShutterButton.hideShutterButton")!!
      }

      if (call.hasArgument("StoragePath")) {
        builder.imageAttributes.outputDirectory = call.argument<String>("StoragePath")!!
      }

      if (call.hasArgument("DefaultColor")) {
        val default = call.argument<String>("DefaultColor")!!
        if (default == "original") {
          builder.colors.imageColorMode = KlippaImageColor.ORIGINAL
        } else if (default == "enhanced") {
          builder.colors.imageColorMode = KlippaImageColor.ENHANCED
        } else if (default == "grayscale") {
          builder.colors.imageColorMode = KlippaImageColor.GRAYSCALE
        } else {
          builder.colors.imageColorMode = KlippaImageColor.ORIGINAL
        }
      }

      if (call.hasArgument("ImageLimit")) {
        builder.imageAttributes.imageLimit = call.argument<Int>("ImageLimit")!!
      }

      if (call.hasArgument("ImageLimitReachedMessage")) {
        builder.messages.imageLimitReached = call.argument<String>("ImageLimitReachedMessage")!!
      }

      if (call.hasArgument("CancelConfirmationMessage")) {
        builder.messages.cancelConfirmationMessage = call.argument<String>("CancelConfirmationMessage")!!
      }

      if (call.hasArgument("DeleteButtonText")) {
        builder.buttonTexts.deleteButtonText = call.argument<String>("DeleteButtonText")!!
      }

      if (call.hasArgument("RetakeButtonText")) {
        builder.buttonTexts.retakeButtonText = call.argument<String>("RetakeButtonText")!!
      }

      if (call.hasArgument("CancelButtonText")) {
        builder.buttonTexts.cancelButtonText = call.argument<String>("CancelButtonText")!!
      }

      if (call.hasArgument("CancelAndDeleteImagesButtonText")) {
        builder.buttonTexts.cancelAndDeleteImagesButtonText = call.argument<String>("CancelAndDeleteImagesButtonText")!!
      }

      if (call.hasArgument("OutputFilename")) {
        builder.imageAttributes.outputFileName = call.argument<String>("OutputFilename")!!
      }

      if (call.hasArgument("ImageMovingSensitivityAndroid")) {
        builder.imageAttributes.imageMovingSensitivity = call.argument<Int>("ImageMovingSensitivityAndroid")!!
      }

      if (call.hasArgument("ImageMovingMessage")) {
        builder.messages.imageMovingMessage = call.argument<String>("ImageMovingMessage")!!
      }

      if (call.hasArgument("OrientationWarningMessage")) {
        builder.messages.orientationWarningMessage = call.argument<String>("OrientationWarningMessage")!!
      }

      if (call.hasArgument("StoreImagesToCameraRoll")) {
        builder.imageAttributes.storeImagesToGallery = call.argument<Boolean>("StoreImagesToCameraRoll")!!
      }

      if (call.hasArgument("ShouldGoToReviewScreenWhenImageLimitReached")) {
        builder.menu.shouldGoToReviewScreenWhenImageLimitReached = call.argument<Boolean>("ShouldGoToReviewScreenWhenImageLimitReached")!!
      }

      if (call.hasArgument("UserCanRotateImage")) {
        builder.menu.userCanRotateImage = call.argument<Boolean>("UserCanRotateImage")!!
      }

      if (call.hasArgument("UserCanCropManually")) {
        builder.menu.userCanCropManually = call.argument<Boolean>("UserCanCropManually")!!
      }

      if (call.hasArgument("UserCanChangeColorSetting")) {
        builder.menu.userCanChangeColorSetting = call.argument<Boolean>("UserCanChangeColorSetting")!!
      }

      val intent = builder.getIntent(context)
      activityPluginBinding?.activity?.startActivity(intent)

      resultHandler = result

    } catch (e: Exception) {
      result.error(E_FAILED_TO_SHOW_SESSION, "Could not launch scanner session", e.message + "\n" + Log.getStackTraceString(e))
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

}
