import 'dart:async';

import 'package:flutter/services.dart';

class ModelOptions {
  /// The name of the model file when using custom object detection.
  String? fileName;

  /// The name of the label file when using custom object detection.
  String? modelLabels;
}

class TimerOptions {
  /// Whether the timerButton is shown or hidden.
  bool? allowed;

  /// Whether automatically capturing of images is enabled. Only available when using a custom object detection model.
  bool? enabled;

  /// The duration of the interval (in seconds) in which images are automatically captured, should be a float.
  num? duration;
}

class Dimensions {
  /// To add extra horizontal padding to the cropped image.
  num? width;

  /// To add extra vertical padding to the cropped image.
  num? height;
}

class SuccessOptions {
  /// After capture, show a checkmark preview with this success message, instead of a preview of the image.
  String? message;

  /// The amount of seconds the success message should be visible for, should be a float.
  num? previewDuration;
}

enum DefaultColor { original, grayscale, enhanced }

class ShutterButton {
  /// Whether to allow or disallow the shutter button to work (can only be disabled if a model is supplied)
  bool? allowShutterButton;

  /// Whether the shutter button should be hidden (only works if allowShutterButton is false)
  bool? hideShutterButton;
}

class CameraMode {
  /// The name of the mode (localized).
  String? name;

  /// The instructions that are shown to the user.
  String? message;

  /// The image that is shown in the instructions (iOS only).
  String? image;
}

enum OutputFormat { jpeg, pdfSingle, pdfMerged }

class CameraConfig {
  /// Global options.

  /// Whether the crop mode (auto edge detection) should be enabled by default.
  bool? defaultCrop;

  /// The warning message when someone should move closer to a document.
  String? moveCloserMessage;

  /// The warning message when the camera preview has to much motion to be able to automatically take a photo.
  String? imageMovingMessage;

  // The warning message when the camera turned out of portrait mode.
  String? orientationWarningMessage;

  /// The max width of the result image.
  num? imageMaxWidth;

  /// The max height of the result image.
  num? imageMaxHeight;

  /// Set the quality (between 0-100) of the jpg encoder. Default is 100.
  num? imageMaxQuality;

  /// The amount of seconds the preview should be visible for, should be a float.
  num? previewDuration;

  /// To limit the amount of images that can be taken.
  num? imageLimit;

  /// The message to display when the limit has reached.
  String? imageLimitReachedMessage;

  /// The text inside of the delete button.
  String? deleteButtonText;

  /// The text inside of the retake button.
  String? retakeButtonText;

  /// The text inside of the cancel button.
  String? cancelButtonText;

  /// The text inside of the cancel alert button.
  String? cancelAndDeleteImagesButtonText;

  /// The text inside of the alert to confirm exiting the scanner.
  String? cancelConfirmationMessage;

  /// The text at the top to indicate the picture count on segmented camera mode.
  String? segmentedModeImageCountMessage;

  /// Whether to go to the Review Screen once the image limit has been reached. (default false)
  bool? shouldGoToReviewScreenWhenImageLimitReached;

  /// Whether the user must confirm the taken photo before the SDK continues. (default false)
  bool? userShouldAcceptResultToContinue;

  /// Whether to hide or show the rotate button in the Review Screen. (default shown/true)
  bool? userCanRotateImage;

  /// Whether to hide or show the cropping button in the Review Screen. (default shown/true)
  bool? userCanCropManually;

  /// Whether to hide or show the color changing button in the Review Screen. (default shown/true)
  bool? userCanChangeColorSetting;

  /// If you would like to use a custom model for object detection. Model + labels file should be packaged in your bundle.
  ModelOptions model = new ModelOptions();

  /// If you would like to enable automatic capturing of images.
  TimerOptions timer = new TimerOptions();

  /// To add extra horizontal and / or vertical padding to the cropped image.
  Dimensions cropPadding = new Dimensions();

  /// After capture, show a checkmark preview with this success message, instead of a preview of the image.
  SuccessOptions success = new SuccessOptions();

  /// Whether to disable/hide the shutterbutton (only works if a model is supplied).
  ShutterButton shutterButton = new ShutterButton();

  /// Whether the camera automatically saves the images to the camera roll (iOS) / gallery (Android). Default true.
  bool? storeImagesToCameraRol;

  /// Whether to perform on-device OCR after scanning completes.
  bool? performOnDeviceOCR;

  /// What the output format will be (jpeg, pdfMerged, pdfSingle). (Default jpeg)
  OutputFormat? outputFormat;

  /// The camera mode for scanning one part documents.
  CameraMode? cameraModeSingle;

  /// The camera mode for scanning documents that consist of multiple pages.
  CameraMode? cameraModeMulti;

  /// The camera mode for scanning long documents in separate parts.
  CameraMode? cameraModeSegmented;

  /// The starting index for which mode will be preselected when starting.
  num? startingIndex;

  /// Whether to allow users to select media from their device (Shows a media button bottom left on the scanner screen).
  bool? userCanPickMediaFromStorage;

  /// Whether the next button in the bottom right of the scanner screen goes to the review screen instead of finishing the session.
  bool? shouldGoToReviewScreenOnFinishPressed;

  /// Android Options

  /// Where to put the image results
  String? storagePath;

  /// What the default color conversion will be (grayscale, original, enhanced).
  DefaultColor? defaultColor;

  /// The filename to be given to the image results.
  String? outputFileName;

  /// The threshold of how sensitive the motion detection is. (lower value is higher sensitivity, default 50)
  num? imageMovingSensitivityAndroid;

  /// iOS Options

  /// The warning message when the camera result is too bright.
  String? imageTooBrightMessage;

  /// The warning message when the camera result is too dark.
  String? imageTooDarkMessage;

  /// The text inside of the color selection alert dialog button named original.
  String? imageColorOriginalText;

  /// The text inside of the color selection alert dialog button named grayscale.
  String? imageColorGrayScaleText;

  /// The text inside of the color selection alert dialog button named enhanced.
  String? imageColorEnhancedText;

  /// The text to finish the scanner on the edit screen.
  String? continueButtonText;

  /// The primary color of the interface, should be a hex RGB color string.
  Color? primaryColor;

  /// The accent color of the interface, should be a hex RGB color string.
  Color? accentColor;

  /// The overlay color (when using document detection), should be a hex RGB color string.
  Color? secondaryColor;

  /// The color of the background of the warning message, should be a hex RGB color string.
  Color? warningBackgroundColor;

  /// The color of the text of the warning message, should be a hex RGB color string.
  Color? warningTextColor;

  /// The amount of opacity for the overlay, should be a float.
  num? overlayColorAlpha;

  /// The color of the menu icons when they are enabled, should be a hex RGB color string.
  Color? iconEnabledColor;

  /// The color of the menu icons when they are enabled, should be a hex RGB color string.
  Color? iconDisabledColor;

  /// The color of the menu icons of the screen where you can review/edit the images, should be a hex RGB color string.
  Color? buttonWithIconForegroundColor;

  /// The color of the menu icons of the screen where you can review/edit the images, should be a hex RGB color string.
  Color? buttonWithIconBackgroundColor;

  /// The text below the crop button in the review screen.
  String? cropEditButtonText;

  /// The text below the filter button in the review screen.
  String? filterEditButtonText;

  /// The text below the rotate button in the review screen.
  String? rotateEditButtonText;

  /// The text below the delete button in the review screen.
  String? deleteEditButtonText;

  /// The text below the cancel button in the crop screen.
  String? cancelCropButtonText;

  /// The text below the expand button in the crop screen.
  String? expandCropButtonText;

  /// The text below the save button in the crop screen.
  String? saveCropButtonText;

  /// Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
  bool? isViewFinderEnabled;

  /// The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 200).
  num? imageMovingSensitivityiOS;

  /// The lower threshold before the warning message informs the environment is too dark (default 0).
  num? brightnessLowerThreshold;

  /// The upper threshold before the warning message informs the environment is too bright (default 6).
  num? brightnessUpperThreshold;
}

/// A helper to convert flutter Color to a hex ARGB.
class KIVHexColor {
  /// Convert the given Flutter [color] object to a hex ARGB string. With our without a leading hash sign based on [leadingHashSign].
  static String flutterColorToHex(Color color, bool leadingHashSign) {
    return '${leadingHashSign ? '#' : ''}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}'
        '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }
}

class KlippaScannerSdk {
  static const MethodChannel _channel =
      const MethodChannel('klippa_scanner_sdk');

  static Future<void> purge() async {
    return await _channel.invokeMethod('purge');
  }

  static Future<Map> startSession(
      final CameraConfig config, String license) async {
    Map<String, dynamic> parameters = {};
    parameters['License'] = license;

    /// Global options.

    if (config.defaultCrop != null) {
      parameters["DefaultCrop"] = config.defaultCrop;
    }

    if (config.imageMaxWidth != null) {
      parameters["ImageMaxWidth"] = config.imageMaxWidth;
    }

    if (config.imageMaxHeight != null) {
      parameters["ImageMaxHeight"] = config.imageMaxHeight;
    }

    if (config.imageMaxQuality != null) {
      parameters["ImageMaxQuality"] = config.imageMaxQuality;
    }

    if (config.previewDuration != null) {
      parameters["PreviewDuration"] = config.previewDuration;
    }

    if (config.model.fileName != null) {
      parameters["Model.fileName"] = config.model.fileName;
    }
    if (config.model.modelLabels != null) {
      parameters["Model.modelLabels"] = config.model.modelLabels;
    }

    if (config.timer.allowed != null) {
      parameters["Timer.allowed"] = config.timer.allowed;
    }
    if (config.timer.enabled != null) {
      parameters["Timer.enabled"] = config.timer.enabled;
    }
    if (config.timer.duration != null) {
      parameters["Timer.duration"] = config.timer.duration;
    }

    if (config.cropPadding.height != null) {
      parameters["CropPadding.height"] = config.cropPadding.height;
    }
    if (config.cropPadding.width != null) {
      parameters["CropPadding.width"] = config.cropPadding.width;
    }

    if (config.success.previewDuration != null) {
      parameters["Success.previewDuration"] = config.success.previewDuration;
    }

    if (config.shutterButton.allowShutterButton != null) {
      parameters["ShutterButton.allowShutterButton"] =
          config.shutterButton.allowShutterButton;
    }
    if (config.shutterButton.hideShutterButton != null) {
      parameters["ShutterButton.hideShutterButton"] =
          config.shutterButton.hideShutterButton;
    }

    if (config.imageLimit != null) {
      parameters["ImageLimit"] = config.imageLimit;
    }

    if (config.defaultColor != null) {
      parameters["DefaultColor"] = config.defaultColor!.name;
    }

    if (config.storeImagesToCameraRol != null) {
      parameters["StoreImagesToCameraRoll"] = config.storeImagesToCameraRol;
    }

    if (config.performOnDeviceOCR != null) {
      parameters["PerformOnDeviceOCR"] = config.performOnDeviceOCR;
    }

    if (config.outputFormat != null) {
      parameters["OutputFormat"] = config.outputFormat;
    }

    if (config.cameraModeSingle != null) {
      parameters["CameraModeSingle"] = {
        'name': config.cameraModeSingle?.name,
        'message': config.cameraModeSingle?.message,
        'image': config.cameraModeSingle?.image
      };
    }

    if (config.cameraModeMulti != null) {
      parameters["CameraModeMulti"] = {
        'name': config.cameraModeMulti?.name,
        'message': config.cameraModeMulti?.message,
        'image': config.cameraModeMulti?.image
      };
    }

    if (config.cameraModeSegmented != null) {
      parameters["CameraModeSegmented"] = {
        'name': config.cameraModeSegmented?.name,
        'message': config.cameraModeSegmented?.message,
        'image': config.cameraModeSegmented?.image
      };
    }

    if (config.startingIndex != null) {
      parameters["StartingIndex"] = config.startingIndex;
    }

    if (config.userCanRotateImage != null) {
      parameters["UserCanRotateImage"] = config.userCanRotateImage;
    }

    if (config.userCanCropManually != null) {
      parameters["UserCanCropManually"] = config.userCanCropManually;
    }

    if (config.userCanChangeColorSetting != null) {
      parameters["UserCanChangeColorSetting"] =
          config.userCanChangeColorSetting;
    }

    if (config.userCanPickMediaFromStorage != null) {
      parameters["UserCanPickMediaFromStorage"] =
          config.userCanPickMediaFromStorage;
    }

    if (config.shouldGoToReviewScreenOnFinishPressed != null) {
      parameters["ShouldGoToReviewScreenOnFinishPressed"] =
          config.shouldGoToReviewScreenOnFinishPressed;
    }

    /// Android only

    if (config.storagePath != null) {
      parameters["StoragePath"] = config.storagePath;
    }

    if (config.outputFileName != null) {
      parameters["OutputFilename"] = config.outputFileName;
    }

    if (config.imageMovingSensitivityAndroid != null) {
      parameters["ImageMovingSensitivityAndroid"] =
          config.imageMovingSensitivityAndroid;
    }

    /// iOS only

    if (config.imageTooBrightMessage != null) {
      parameters["ImageTooBrightMessage"] = config.imageTooBrightMessage;
    }

    if (config.imageTooDarkMessage != null) {
      parameters["ImageTooDarkMessage"] = config.imageTooDarkMessage;
    }

    if (config.moveCloserMessage != null) {
      parameters["MoveCloserMessage"] = config.moveCloserMessage;
    }

    if (config.imageMovingMessage != null) {
      parameters["ImageMovingMessage"] = config.imageMovingMessage;
    }

    if (config.orientationWarningMessage != null) {
      parameters["OrientationWarningMessage"] =
          config.orientationWarningMessage;
    }

    if (config.success.message != null) {
      parameters["Success.message"] = config.success.message;
    }

    if (config.imageLimitReachedMessage != null) {
      parameters["ImageLimitReachedMessage"] = config.imageLimitReachedMessage;
    }

    if (config.segmentedModeImageCountMessage != null) {
      parameters["SegmentedModeImageCountMessage"] =
          config.segmentedModeImageCountMessage;
    }

    if (config.cancelConfirmationMessage != null) {
      parameters["CancelConfirmationMessage"] =
          config.cancelConfirmationMessage;
    }

    if (config.deleteButtonText != null) {
      parameters["DeleteButtonText"] = config.deleteButtonText;
    }

    if (config.retakeButtonText != null) {
      parameters["RetakeButtonText"] = config.retakeButtonText;
    }

    if (config.cancelButtonText != null) {
      parameters["CancelButtonText"] = config.cancelButtonText;
    }

    if (config.cancelAndDeleteImagesButtonText != null) {
      parameters["CancelAndDeleteImagesButtonText"] =
          config.cancelAndDeleteImagesButtonText;
    }

    if (config.imageColorOriginalText != null) {
      parameters["ImageColorOriginalText"] = config.imageColorOriginalText;
    }

    if (config.imageColorGrayScaleText != null) {
      parameters["ImageColorGrayScaleText"] = config.imageColorGrayScaleText;
    }

    if (config.imageColorEnhancedText != null) {
      parameters["ImageColorEnhancedText"] = config.imageColorEnhancedText;
    }

    if (config.continueButtonText != null) {
      parameters["ContinueButtonText"] = config.continueButtonText;
    }

    if (config.shouldGoToReviewScreenWhenImageLimitReached != null) {
      parameters["ShouldGoToReviewScreenWhenImageLimitReached"] =
          config.shouldGoToReviewScreenWhenImageLimitReached;
    }

    if (config.userShouldAcceptResultToContinue != null) {
      parameters["UserShouldAcceptResultToContinue"] =
          config.userShouldAcceptResultToContinue;
    }

    if (config.primaryColor != null) {
      parameters["PrimaryColor"] =
          KIVHexColor.flutterColorToHex(config.primaryColor!, true);
    }

    if (config.accentColor != null) {
      parameters["AccentColor"] =
          KIVHexColor.flutterColorToHex(config.accentColor!, true);
    }

    if (config.secondaryColor != null) {
      parameters["SecondaryColor"] =
          KIVHexColor.flutterColorToHex(config.secondaryColor!, true);
    }

    if (config.overlayColorAlpha != null) {
      parameters["OverlayColorAlpha"] = config.overlayColorAlpha;
    }

    if (config.warningBackgroundColor != null) {
      parameters["WarningBackgroundColor"] =
          KIVHexColor.flutterColorToHex(config.warningBackgroundColor!, true);
    }

    if (config.warningTextColor != null) {
      parameters["WarningTextColor"] =
          KIVHexColor.flutterColorToHex(config.warningTextColor!, true);
    }

    if (config.iconEnabledColor != null) {
      parameters["IconEnabledColor"] =
          KIVHexColor.flutterColorToHex(config.iconEnabledColor!, true);
    }

    if (config.iconDisabledColor != null) {
      parameters["IconDisabledColor"] =
          KIVHexColor.flutterColorToHex(config.iconDisabledColor!, true);
    }

    if (config.buttonWithIconForegroundColor != null) {
      parameters["ButtonWithIconForegroundColor"] =
          KIVHexColor.flutterColorToHex(
              config.buttonWithIconForegroundColor!, true);
    }

    if (config.buttonWithIconBackgroundColor != null) {
      parameters["ButtonWithIconBackgroundColor"] =
          KIVHexColor.flutterColorToHex(
              config.buttonWithIconBackgroundColor!, true);
    }

    if (config.isViewFinderEnabled != null) {
      parameters["IsViewFinderEnabled"] = config.isViewFinderEnabled;
    }

    if (config.imageMovingSensitivityiOS != null) {
      parameters["ImageMovingSensitivityiOS"] =
          config.imageMovingSensitivityiOS;
    }

    if (config.brightnessLowerThreshold != null) {
      parameters["BrightnessLowerThreshold"] = config.brightnessLowerThreshold;
    }

    if (config.brightnessUpperThreshold != null) {
      parameters["BrightnessUpperThreshold"] = config.brightnessUpperThreshold;
    }

    final Map startSessionResult =
        await _channel.invokeMethod('startSession', parameters);
    return startSessionResult;
  }
}
