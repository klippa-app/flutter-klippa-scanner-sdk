package com.example.klippa_scanner_sdk


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

      if (call.hasArgument("ShutterButton.hideShutterbutton")) {
        KlippaScanner.shutterButton.hideShutterButton = call.argument<Boolean>("ShutterButton.hideShutterbutton")!!
      }

      if (call.hasArgument("StoragePath")) {
        KlippaScanner.images.outputDirectory = call.argument<String>("StoragePath")!!
      }

      if (call.hasArgument("DefaultColor")) {
        val default = call.argument<String>("DefaultColor")!!
        if (default == "original") {
          KlippaScanner.colors.defaultColor = KlippaScanner.DefaultColor.ORIGINAL
        } else {
          KlippaScanner.colors.defaultColor = KlippaScanner.DefaultColor.GRAYSCALE
        }
      }

      if (call.hasArgument("ImageLimit")) {
        KlippaScanner.images.imageLimit = call.argument<Int>("ImageLimit")!!
      }

      if (call.hasArgument("ImageLimitReachedMessage")) {
        KlippaScanner.messages.imageLimitReached = call.argument<String>("ImageLimitReachedMessage")!!
      }

      if (call.hasArgument("OutputFilename")) {
        KlippaScanner.images.outputFileName = call.argument<String>("OutputFilename")!!
      }

      if (call.hasArgument("ImageMovingSensitivityAndroid")) {
        KlippaScanner.images.imageMovingSensitivity = call.argument<Int>("ImageMovingSensitivityAndroid")!!
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

      val images: ArrayList<Image> = extras.getParcelableArrayList<Image>(KlippaScanner.IMAGES) as ArrayList<Image>
      Toast.makeText(context, "Result was " + images.size + " images", Toast.LENGTH_LONG).show()
      return true
    } else if (requestCode == this.SESSION_REQUEST_CODE && resultCode == Activity.RESULT_CANCELED) {
      var error: String? = null
      if (data != null) {
        error = data.getStringExtra(KlippaScanner.ERROR)
      }
      if (error != null) {
        Toast.makeText(context, "Scanner was canceled with error: $error", Toast.LENGTH_LONG).show()
        println(error)
      } else {
        Toast.makeText(context, "Scanner was canceled", Toast.LENGTH_LONG).show()
      }
      return false
    }
    return false
  }
}
