package com.klippa.scanner.klippa_scanner_sdk


import android.app.Activity
import android.content.Context
import android.util.Log
import android.util.Size
import com.klippa.scanner.KlippaScannerBuilder
import com.klippa.scanner.KlippaScannerListener
import com.klippa.scanner.model.Failure
import com.klippa.scanner.model.Instructions
import com.klippa.scanner.model.KlippaCameraModes
import com.klippa.scanner.model.KlippaDocumentMode
import com.klippa.scanner.model.KlippaImageColor
import com.klippa.scanner.model.KlippaMultipleDocumentMode
import com.klippa.scanner.model.KlippaObjectDetectionModel
import com.klippa.scanner.model.KlippaScannerResult
import com.klippa.scanner.model.KlippaSegmentedDocumentMode
import com.klippa.scanner.model.KlippaSingleDocumentMode
import com.klippa.scanner.model.Success
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** KlippaScannerSdkPlugin */
class KlippaScannerSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  private var activityPluginBinding : ActivityPluginBinding? = null

  private val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
  private val E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
  private val E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
  private val E_CANCELED = "E_CANCELED"
  private var resultHandler : Result? = null

  private var singleDocumentModeInstructionsDismissed = false
  private var multiDocumentModeInstructionsDismissed = false
  private var segmentedDocumentModeInstructionsDismissed = false

  private val listener = object : KlippaScannerListener {

    override fun klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
      val images: MutableList<Map<String, String>> = mutableListOf()

      for (image in result.images) {
        val imageDict = mapOf("Filepath" to image.location)
        images.add(imageDict)
      }

      val cropEnabled: Boolean = result.cropEnabled
      val timerEnabled: Boolean = result.timerEnabled

      val resultDict = mapOf(
        "Images" to images,
        "Crop" to cropEnabled,
        "TimerEnabled" to timerEnabled,
        "SingleDocumentModeInstructionsDismissed" to singleDocumentModeInstructionsDismissed,
        "MultiDocumentModeInstructionsDismissed" to multiDocumentModeInstructionsDismissed,
        "SegmentedDocumentModeInstructionsDismissed" to segmentedDocumentModeInstructionsDismissed
        )

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

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
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



  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "startSession") {
      startSession(call, result)
    } else {
      result.notImplemented()
    }
  }

  private fun startSession(call: MethodCall, result: Result) {
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

      if (call.hasArgument("Model.fileName") && call.hasArgument("Model.modelLabels")) {
        val objectDetectionModel = KlippaObjectDetectionModel()

        objectDetectionModel.modelName = call.argument<String>("Model.fileName")!!
        objectDetectionModel.modelLabels = call.argument<String>("Model.modelLabels")!!
        objectDetectionModel.runWithModel = true

        builder.objectDetectionModel = objectDetectionModel
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

      if (call.hasArgument("ShutterButton.allowShutterButton")) {
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
        when (default) {
            "original" -> {
              builder.colors.imageColorMode = KlippaImageColor.ORIGINAL
            }
            "enhanced" -> {
              builder.colors.imageColorMode = KlippaImageColor.ENHANCED
            }
            "grayscale" -> {
              builder.colors.imageColorMode = KlippaImageColor.GRAYSCALE
            }
            else -> {
              builder.colors.imageColorMode = KlippaImageColor.ORIGINAL
            }
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

      val modes: MutableList<KlippaDocumentMode> = mutableListOf()

      call.argument<HashMap<String, String>>("CameraModeSingle")?.let { cameraModeSingle ->
        val singleDocumentMode = KlippaSingleDocumentMode()
        cameraModeSingle["name"]?.let { name ->
          singleDocumentMode.name = name
        }
        cameraModeSingle["message"]?.let { message ->
          singleDocumentMode.instructions = Instructions(message, dismissHandler = {
            singleDocumentModeInstructionsDismissed = true
          })
        }

        modes.add(singleDocumentMode)
      }

      call.argument<HashMap<String, String>>("CameraModeMulti")?.let { cameraModeMulti ->
        val multiDocumentMode = KlippaMultipleDocumentMode()
        cameraModeMulti["name"]?.let { name ->
          multiDocumentMode.name = name
        }
        cameraModeMulti["message"]?.let { message ->
          multiDocumentMode.instructions = Instructions(message, dismissHandler = {
            multiDocumentModeInstructionsDismissed = true
          })
        }

        modes.add(multiDocumentMode)
      }

      call.argument<HashMap<String, String>>("CameraModeSegmented")?.let { cameraModeSegmented ->
        val segmentedDocumentMode = KlippaSegmentedDocumentMode()
        cameraModeSegmented["name"]?.let { name ->
          segmentedDocumentMode.name = name
        }
        cameraModeSegmented["message"]?.let { message ->
          segmentedDocumentMode.instructions = Instructions(message, dismissHandler = {
            segmentedDocumentModeInstructionsDismissed = true
          })
        }

        modes.add(segmentedDocumentMode)
      }

      if (modes.isNotEmpty()) {
        var index = 0
        call.argument<Int>("StartingIndex")?.let {
          index = it
        }
        val cameraModes = KlippaCameraModes(
          modes = modes,
          startingIndex = index
        )
        builder.cameraModes = cameraModes
      }

      when (val intent = builder.build(context)) {
        is Failure -> {
          result.error(E_FAILED_TO_SHOW_SESSION, "Could not launch scanner session", intent.reason.message + "\n" + Log.getStackTraceString(intent.reason.cause))
          return
        }
        is Success -> {
          activityPluginBinding?.activity?.startActivity(intent.value)
        }
      }


      resultHandler = result

    } catch (e: Exception) {
      result.error(E_FAILED_TO_SHOW_SESSION, "Could not launch scanner session", e.message + "\n" + Log.getStackTraceString(e))
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

}
