package com.klippa.scanner.klippa_scanner_sdk


import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.klippa.scanner.KlippaScanner
import com.klippa.scanner.`object`.Image
import android.util.Size
import android.widget.Toast
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** KlippaScannerSdkPlugin */
class KlippaScannerSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var activityPluginBinding : ActivityPluginBinding? = null

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
      } else {
        KlippaScanner.license = call.argument<String>("License")!!
      }

      if (call.hasArgument("AllowMultipleDocuments")) {
        KlippaScanner.menu.allowMultiDocumentsMode = call.argument<Boolean>("AllowMultipleDocuments")!!
      }

      if (call.hasArgument("DefaultMultipleDocuments")) {
        KlippaScanner.menu.isMultiDocumentsModeEnabled = call.argument<Boolean>("DefaultMultipleDocuments")!!
      }

      if (call.hasArgument("DefaultCrop")) {
        KlippaScanner.menu.isCropEnabled = call.argument<Boolean>("DefaultCrop")!!
      }

      if (call.hasArgument("MoveCloserMessage")) {
        KlippaScanner.messages.moveCloserMessage = call.argument<String>("MoveCloserMessage")!!
      }

      if (call.hasArgument("ImageMaxWidth")) {
        KlippaScanner.images.resolutionMaxWidth = call.argument<Int>("ImageMaxWidth")!!
      }

      if (call.hasArgument("ImageMaxHeight")) {
        KlippaScanner.images.resolutionMaxWidth = call.argument<Int>("ImageMaxHeight")!!
      }

      if (call.hasArgument("ImageMaxQuality")) {
        KlippaScanner.images.outputQuality = call.argument<Int>("ImageMaxQuality")!!
      }

      if (call.hasArgument("PreviewDuration")) {
        KlippaScanner.durations.previewDuration = call.argument<Double>("PreviewDuration")!!
      }

      if (call.hasArgument("Model.fileName")) {
        KlippaScanner.model.modelName = call.argument<String>("Model.fileName")!!
      }

      if (call.hasArgument("Model.modelLabels")) {
        KlippaScanner.model.modelLabels = call.argument<String>("Model.modelLabels")!!
      }

      if (call.hasArgument("Timer.allowed")) {
        KlippaScanner.menu.allowTimer = call.argument<Boolean>("Timer.allowed")!!
      }

      if (call.hasArgument("Timer.enabled")) {
        KlippaScanner.menu.isTimerEnabled = call.argument<Boolean>("Timer.enabled")!!
      }

      if (call.hasArgument("Timer.duration")) {
        KlippaScanner.durations.timerDuration = call.argument<Double>("Timer.duration")!!
      }

      var height: Int = 0
      var width: Int = 0

      if (call.hasArgument("CropPadding.height")) {
        height = call.argument<Int>("CropPadding.height")!!
      }

      if (call.hasArgument("CropPadding.width")) {
        width = call.argument<Int>("CropPadding.width")!!
      }

      KlippaScanner.images.cropPadding = Size(width, height)

      if (call.hasArgument("Success.previewDuration")) {
        KlippaScanner.durations.successPreviewDuration = call.argument<Double>("Success.previewDuration")!!
      }

      if (call.hasArgument("Success.message")) {
        KlippaScanner.messages.successMessage = call.argument<String>("Success.message")!!
      }

      if (call.hasArgument("ShutterButton.allowshutterButton")) {
        KlippaScanner.shutterButton.allowShutterButton = call.argument<Boolean>("ShutterButton.allowshutterButton")!!
      }

      if (call.hasArgument("ShutterButton.hideShutterButton")) {
        KlippaScanner.shutterButton.hideShutterButton = call.argument<Boolean>("ShutterButton.hideShutterButton")!!
      }

      if (call.hasArgument("StoragePath")) {
        KlippaScanner.images.outputDirectory = call.argument<String>("StoragePath")!!
      }

      if (call.hasArgument("DefaultColor")) {
        val default = call.argument<String>("DefaultColor")!!
        if (default == "original") {
          KlippaScanner.colors.defaultColor = KlippaScanner.DefaultColor.ORIGINAL
        } else if (default == "enhanced") {
          KlippaScanner.colors.defaultColor = KlippaScanner.DefaultColor.ENHANCED
        } else if (default == "grayscale") {
          KlippaScanner.colors.defaultColor = KlippaScanner.DefaultColor.GRAYSCALE
        } else {
          KlippaScanner.colors.defaultColor = KlippaScanner.DefaultColor.ORIGINAL
        }
      }

      if (call.hasArgument("ImageLimit")) {
        KlippaScanner.images.imageLimit = call.argument<Int>("ImageLimit")!!
      }

      if (call.hasArgument("ImageLimitReachedMessage")) {
        KlippaScanner.messages.imageLimitReached = call.argument<String>("ImageLimitReachedMessage")!!
      }

      if (call.hasArgument("CancelConfirmationMessage")) {
        KlippaScanner.messages.cancelConfirmationMessage = call.argument<String>("CancelConfirmationMessage")!!
      }

      if (call.hasArgument("DeleteButtonText")) {
        KlippaScanner.buttonTexts.deleteButtonText = call.argument<String>("DeleteButtonText")!!
      }

      if (call.hasArgument("RetakeButtonText")) {
        KlippaScanner.buttonTexts.retakeButtonText = call.argument<String>("RetakeButtonText")!!
      }

      if (call.hasArgument("CancelButtonText")) {
        KlippaScanner.buttonTexts.cancelButtonText = call.argument<String>("CancelButtonText")!!
      }

      if (call.hasArgument("CancelAndDeleteImagesButtonText")) {
        KlippaScanner.buttonTexts.cancelAndDeleteImagesButtonText = call.argument<String>("CancelAndDeleteImagesButtonText")!!
      }
      
      if (call.hasArgument("OutputFilename")) {
        KlippaScanner.images.outputFileName = call.argument<String>("OutputFilename")!!
      }

      if (call.hasArgument("ImageMovingSensitivityAndroid")) {
        KlippaScanner.images.imageMovingSensitivity = call.argument<Int>("ImageMovingSensitivityAndroid")!!
      }

      if (call.hasArgument("ImageMovingMessage")) {
        KlippaScanner.messages.imageMovingMessage = call.argument<String>("ImageMovingMessage")!!
      }

      if (call.hasArgument("OrientationWarningMessage")) {
        KlippaScanner.messages.orientationWarningMessage = call.argument<String>("OrientationWarningMessage")!!
      }

      if (call.hasArgument("StoreImagesToCameraRoll")) {
        KlippaScanner.storeImagesToGallery = call.argument<Boolean>("StoreImagesToCameraRoll")!!
      }

      if (call.hasArgument("ShouldGoToReviewScreenWhenImageLimitReached")) {
        KlippaScanner.menu.shouldGoToReviewScreenWhenImageLimitReached = call.argument<Boolean>("ShouldGoToReviewScreenWhenImageLimitReached")!!
      }

      if (call.hasArgument("UserCanRotateImage")) {
        KlippaScanner.menu.userCanRotateImage = call.argument<Boolean>("UserCanRotateImage")!!
      }

      if (call.hasArgument("UserCanCropManually")) {
        KlippaScanner.menu.userCanCropManually = call.argument<Boolean>("UserCanCropManually")!!
      }

      if (call.hasArgument("UserCanChangeColorSetting")) {
        KlippaScanner.menu.userCanChangeColorSetting = call.argument<Boolean>("UserCanChangeColorSetting")!!
      }

      val klippaScannerIntent = Intent(context, KlippaScanner::class.java)
      resultHandler = result
      activityPluginBinding!!.addActivityResultListener(this)
      activityPluginBinding!!.activity.startActivityForResult(klippaScannerIntent, SESSION_REQUEST_CODE)

    } catch (e: Exception) {
      result.error(E_FAILED_TO_SHOW_SESSION, "Could not launch scanner session", e.message + "\n" + Log.getStackTraceString(e))
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == this.SESSION_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
      val receivedData = data ?: return false
      val extras = receivedData.extras ?: return false

      val receivedImages: ArrayList<Image> = extras.getParcelableArrayList<Image>(KlippaScanner.IMAGES) as ArrayList<Image>

      val images: MutableList<Map<String, String>> = mutableListOf()

      for (image in receivedImages) {
        val imageDict = mapOf("Filepath" to image.filePath)
        images.add(imageDict)
      }

      val multipleDocuments: Boolean = extras.getBoolean(KlippaScanner.CREATE_MULTIPLE_RECEIPTS)
      val cropEnabled: Boolean = extras.getBoolean(KlippaScanner.CROP)
      val timerEnabled: Boolean = extras.getBoolean(KlippaScanner.TIMER_ENABLED)

      val resultDict = mapOf(
        "Images" to images,
        "MultipleDocuments" to multipleDocuments, 
        "Crop" to cropEnabled, 
        "TimerEnabled" to timerEnabled)
      
      resultHandler?.success(resultDict)
      resultHandler = null
      return true
    } else if (requestCode == this.SESSION_REQUEST_CODE && resultCode == Activity.RESULT_CANCELED) {
      var error: String? = null
      if (data != null) {
        error = data.getStringExtra(KlippaScanner.ERROR)
      }
      if (error != null) {
        resultHandler?.error(E_CANCELED, "Scanner was canceled with error: $error", null)
      } else {
        resultHandler?.error(E_CANCELED, "Scanner was canceled", null)
      }
      return false
    }
    return false
  }
}
