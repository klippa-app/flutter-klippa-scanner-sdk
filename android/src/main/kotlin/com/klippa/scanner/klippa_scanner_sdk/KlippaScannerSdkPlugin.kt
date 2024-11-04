package com.klippa.scanner.klippa_scanner_sdk


import android.content.Intent
import com.klippa.scanner.ScannerFinishedReason
import com.klippa.scanner.ScannerSession
import com.klippa.scanner.ScannerSession.Companion.KLIPPA_ERROR
import com.klippa.scanner.ScannerSession.Companion.KLIPPA_RESULT
import com.klippa.scanner.model.Instructions
import com.klippa.scanner.model.KlippaCameraModes
import com.klippa.scanner.model.KlippaDocumentMode
import com.klippa.scanner.model.KlippaError
import com.klippa.scanner.model.KlippaImageColor
import com.klippa.scanner.model.KlippaMultipleDocumentMode
import com.klippa.scanner.model.KlippaObjectDetectionModel
import com.klippa.scanner.model.KlippaScannerResult
import com.klippa.scanner.model.KlippaSegmentedDocumentMode
import com.klippa.scanner.model.KlippaSingleDocumentMode
import com.klippa.scanner.model.KlippaSize
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

    companion object {
        private const val E_ACTIVITY_DOES_NOT_EXIST = "E_ACTIVITY_DOES_NOT_EXIST"
        private const val E_MISSING_SESSION_TOKEN = "E_MISSING_SESSION_TOKEN"
        private const val E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
        private const val E_CANCELED = "E_CANCELED"

        private const val REQUEST_CODE = 99991802
    }

    private var resultHandler: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel =
            MethodChannel(flutterPluginBinding.binaryMessenger, "klippa_scanner_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activityPluginBinding = binding
        binding.addActivityResultListener(this)
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
        val activity = activityPluginBinding?.activity ?: kotlin.run {
            result.error(E_ACTIVITY_DOES_NOT_EXIST, "Activity doesn't exist", null)
            return
        }


        try {
            val license = call.argument<String>("License") ?: kotlin.run {
                result.error(E_MISSING_SESSION_TOKEN, "Missing license", null)
                return
            }

            val scannerSession = ScannerSession(license)


            call.argument<Boolean>("DefaultCrop")?.let {
                scannerSession.menu.isCropEnabled = it
            }

            call.argument<Int>("ImageMaxWidth")?.let {
                scannerSession.imageAttributes.resolutionMaxWidth = it
            }

            call.argument<Int>("ImageMaxHeight")?.let {
                scannerSession.imageAttributes.resolutionMaxHeight = it
            }

            call.argument<Int>("ImageMaxQuality")?.let {
                scannerSession.imageAttributes.outputQuality = it
            }

            call.argument<Double>("PreviewDuration")?.let {
                scannerSession.durations.previewDuration = it
            }

            call.argument<String>("Model.fileName")?.let { fileName ->
                call.argument<String>("Model.modelLabels")?.let { labelName ->
                    val objectDetectionModel = KlippaObjectDetectionModel().apply {
                        modelName = fileName
                        modelLabels = labelName
                    }
                    scannerSession.objectDetectionModel = objectDetectionModel
                }
            }

            call.argument<Boolean>("Timer.allowed")?.let {
                scannerSession.menu.allowTimer = it
            }

            call.argument<Boolean>("Timer.enabled")?.let {
                scannerSession.menu.isTimerEnabled = it
            }

            call.argument<Double>("Timer.duration")?.let {
                scannerSession.durations.timerDuration = it
            }

            val width = call.argument<Int>("CropPadding.width") ?: 0
            val height = call.argument<Int>("CropPadding.height") ?: 0

            scannerSession.imageAttributes.cropPadding = KlippaSize(width, height)

            call.argument<Double>("Success.previewDuration")?.let {
                scannerSession.durations.successPreviewDuration = it
            }

            call.argument<Boolean>("ShutterButton.allowShutterButton")?.let {
                scannerSession.shutterButton.allowShutterButton = it
            }

            call.argument<Boolean>("ShutterButton.hideShutterButton")?.let {
                scannerSession.shutterButton.hideShutterButton = it
            }

            call.argument<String>("StoragePath")?.let {
                scannerSession.imageAttributes.outputDirectory = it
            }

            call.argument<String>("DefaultColor")?.let {
                when (it) {
                    "original" -> {
                        scannerSession.imageAttributes.imageColorMode = KlippaImageColor.ORIGINAL
                    }
                    "enhanced" -> {
                        scannerSession.imageAttributes.imageColorMode = KlippaImageColor.ENHANCED
                    }
                    "grayscale" -> {
                        scannerSession.imageAttributes.imageColorMode = KlippaImageColor.GRAYSCALE
                    }
                }
            }

            call.argument<Int>("ImageLimit")?.let {
                scannerSession.imageAttributes.imageLimit = it
            }

            call.argument<String>("OutputFilename")?.let {
                scannerSession.imageAttributes.outputFileName = it
            }

            call.argument<Int>("ImageMovingSensitivityAndroid")?.let {
                scannerSession.imageAttributes.imageMovingSensitivity = it
            }

            call.argument<Boolean>("StoreImagesToCameraRoll")?.let {
                scannerSession.imageAttributes.storeImagesToGallery = it
            }

            call.argument<Boolean>("ShouldGoToReviewScreenWhenImageLimitReached")?.let {
                scannerSession.menu.shouldGoToReviewScreenWhenImageLimitReached = it
            }

            call.argument<Boolean>("UserCanRotateImage")?.let {
                scannerSession.menu.userCanRotateImage = it
            }

            call.argument<Boolean>("UserCanCropManually")?.let {
                scannerSession.menu.userCanCropManually = it
            }

            call.argument<Boolean>("UserCanChangeColorSetting")?.let {
                scannerSession.menu.userCanChangeColorSetting = it
            }


            val modes: MutableList<KlippaDocumentMode> = mutableListOf()

            call.argument<HashMap<String, String>>("CameraModeSingle")?.let { cameraModeSingle ->
                val singleDocumentMode = KlippaSingleDocumentMode()
                cameraModeSingle["name"]?.let { name ->
                    singleDocumentMode.name = name
                }
                cameraModeSingle["message"]?.let { message ->
                    singleDocumentMode.instructions = Instructions(singleDocumentMode.name, message)
                }

                modes.add(singleDocumentMode)
            }

            call.argument<HashMap<String, String>>("CameraModeMulti")?.let { cameraModeMulti ->
                val multiDocumentMode = KlippaMultipleDocumentMode()
                cameraModeMulti["name"]?.let { name ->
                    multiDocumentMode.name = name
                }
                cameraModeMulti["message"]?.let { message ->
                    multiDocumentMode.instructions = Instructions(multiDocumentMode.name, message)
                }

                modes.add(multiDocumentMode)
            }

            call.argument<HashMap<String, String>>("CameraModeSegmented")?.let { cameraModeSegmented ->
                val segmentedDocumentMode = KlippaSegmentedDocumentMode()
                cameraModeSegmented["name"]?.let { name ->
                    segmentedDocumentMode.name = name
                }
                cameraModeSegmented["message"]?.let { message ->
                    segmentedDocumentMode.instructions = Instructions(segmentedDocumentMode.name, message)
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
                scannerSession.cameraModes = cameraModes
            }

            val intent = scannerSession.getIntent(activity)
            resultHandler = result
            activity.startActivityForResult(intent, REQUEST_CODE)
        } catch (e: Exception) {
            result.error(
                E_FAILED_TO_SHOW_SESSION,
                "Could not launch scanner session",
                e.message + "\n" + e.stackTrace
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    data object UnknownError: KlippaError {
        private fun readResolve(): Any = UnknownError
        override fun message(): String = "Unknown Error"
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        val reason = ScannerFinishedReason.mapResultCode(resultCode)

        when (reason) {
            ScannerFinishedReason.FINISHED -> {
                val result =
                    data?.serializable<KlippaScannerResult>(KLIPPA_RESULT) ?: kotlin.run {
                        klippaScannerDidFailWithError(UnknownError)
                        return true
                    }
                klippaScannerDidFinishScanningWithResult(result)
            }
            ScannerFinishedReason.ERROR -> {
                val error =
                    data?.serializable<KlippaError>(KLIPPA_ERROR) ?: kotlin.run {
                        klippaScannerDidFailWithError(UnknownError)
                        return true
                    }
                klippaScannerDidFailWithError(error)
            }
            ScannerFinishedReason.CANCELED -> {
                klippaScannerDidCancel()
            }
            else -> klippaScannerDidFailWithError(UnknownError)
        }
        return true
    }

    private fun klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
        val images: MutableList<Map<String, String>> = mutableListOf()

        for (image in result.images) {
            val imageDict = mapOf("Filepath" to image.location)
            images.add(imageDict)
        }

        val cropEnabled: Boolean = result.cropEnabled
        val timerEnabled: Boolean = result.timerEnabled

        val singleDocumentModeInstructionsDismissed = result.dismissedInstructions["SINGLE_DOCUMENT"] ?: false
        val multiDocumentModeInstructionsDismissed = result.dismissedInstructions["MULTIPLE_DOCUMENT"] ?: false
        val segmentedDocumentModeInstructionsDismissed = result.dismissedInstructions["SEGMENTED_DOCUMENT"] ?: false

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

    private fun klippaScannerDidFailWithError(error: KlippaError) {
        resultHandler?.error(E_CANCELED, "Scanner was canceled with error: ${error.message()}", null)
        resultHandler = null
    }

    private fun klippaScannerDidCancel() {
        resultHandler?.error(E_CANCELED, "Scanner was canceled", null)
        resultHandler = null
    }


}
