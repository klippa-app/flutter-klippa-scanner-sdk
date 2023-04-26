import Flutter
import UIKit
import KlippaScanner

public class SwiftKlippaScannerSdkPlugin: NSObject, FlutterPlugin, KlippaScannerDelegate {
    private var resultHandler: FlutterResult? = nil
    private var E_MISSING_LICENSE = "E_MISSING_LICENSE"
    private var E_FAILED_TO_SHOW_SESSION = "E_FAILED_TO_SHOW_SESSION"
    private var E_CANCELED = "E_CANCELED"
    private var E_UNKNOWN_ERROR = "E_UNKNOWN_ERROR"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "klippa_scanner_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftKlippaScannerSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "startSession" {
            startSession(call, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func startSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments else {
            result(FlutterError.init(code: E_UNKNOWN_ERROR, message: "Unknown error", details: nil))
            return
        }

        let builderArgs = args as? [String: Any]

        guard let license = builderArgs?["License"] else {
            result(FlutterError.init(code: E_MISSING_LICENSE, message: "Missing license", details: nil))
            return
        }

        let builder = KlippaScannerBuilder(builderDelegate: self, license: license as? String ?? "")

        if let allowMultipleDocumentsMode = builderArgs?["AllowMultipleDocuments"] {
            builder.klippaMenu.allowMultipleDocumentsMode = allowMultipleDocumentsMode as? Bool ?? true
        }

        if let isMultipleDocumentsModeEnabled = builderArgs?["DefaultMultipleDocuments"] {
            builder.klippaMenu.isMultipleDocumentsModeEnabled = isMultipleDocumentsModeEnabled as? Bool ?? false
        }

        if let isCropEnabled = builderArgs?["DefaultCrop"] {
            builder.klippaMenu.isCropEnabled = isCropEnabled as? Bool ?? true
        }

        if let moveCloserMessage = builderArgs?["MoveCloserMessage"] {
            builder.klippaMessages.moveCloserMessage = moveCloserMessage as? String ?? ""
        }

        if let imageMovingMessage = builderArgs?["ImageMovingMessage"] {
            builder.klippaMessages.imageMovingMessage = imageMovingMessage as? String ?? ""
        }

        if let orientationWarningMessage = builderArgs?["OrientationWarningMessage"] {
            builder.klippaMessages.orientationWarningMessage = orientationWarningMessage as? String ?? ""
        }

        if let imageMaxWidth = builderArgs?["ImageMaxWidth"] {
            builder.klippaImageAttributes.imageMaxWidth = imageMaxWidth as? CGFloat ?? 0
        }

        if let imageMaxHeight = builderArgs?["ImageMaxHeight"] {
            builder.klippaImageAttributes.imageMaxHeight = imageMaxHeight as? CGFloat ?? 0
        }

        if let imageMaxQuality = builderArgs?["ImageMaxQuality"] {
            builder.klippaImageAttributes.imageMaxQuality = imageMaxQuality as? CGFloat ?? 100
        }

        if let previewDuration = builderArgs?["PreviewDuration"] {
            builder.klippaDurations.previewDuration = previewDuration as? Double ?? 0
        }

        if let isTimerAllowed = builderArgs?["Timer.allowed"] {
            builder.klippaMenu.allowTimer = isTimerAllowed as? Bool ?? false
        }

        if let isTimerEnabled = builderArgs?["Timer.enabled"] {
            builder.klippaMenu.isTimerEnabled = isTimerEnabled as? Bool ?? false
        }

        if let timerDuration = builderArgs?["Timer.duration"] {
            builder.klippaDurations.timerDuration = timerDuration as? Double ?? 0
        }

        let width = builderArgs?["CropPadding.width"] as? Int ?? 0
        let height = builderArgs?["CropPadding.height"] as? Int ?? 0

        builder.klippaImageAttributes.cropPadding = CGSize(width:  width, height: height)

        if let successPreviewDuration = builderArgs?["Success.previewDuration"] {
            builder.klippaDurations.successPreviewDuration = successPreviewDuration as? Double ?? 0
        }

        if let successMessage = builderArgs?["Success.message"] {
            builder.klippaMessages.successMessage = successMessage as? String ?? ""
        }

        if let allowShutterButton = builderArgs?["ShutterButton.allowShutterButton"] {
            if let hideShutterButton = builderArgs?["ShutterButton.hideShutterButton"] {
                builder.klippaShutterbutton.allowShutterButton = allowShutterButton as? Bool ?? true
                builder.klippaShutterbutton.hideShutterButton = hideShutterButton as? Bool ?? false
            }
        }

        if let imageTooBrightMessage = builderArgs?["ImageTooBrightMessage"] {
            builder.klippaMessages.imageTooBrightMessage = imageTooBrightMessage as? String ?? ""
        }

        if let imageTooDarkMessage = builderArgs?["ImageTooDarkMessage"] {
            builder.klippaMessages.imageTooDarkMessage = imageTooDarkMessage  as? String ?? ""
        }

        if let defaultColor = builderArgs?["DefaultColor"] {
            let imageColor = defaultColor  as? String ?? "original"
            switch imageColor {
            case "grayscale":
                builder.klippaColors.imageColor = .grayscale
            case "enhanced":
                builder.klippaColors.imageColor = .enhanced
            default:
                builder.klippaColors.imageColor = .original
            }
        }

        if let imageColorOriginalText = builderArgs?["ImageColorOriginalText"] {
            builder.klippaButtonTexts.imageColorOriginalText = imageColorOriginalText  as? String ?? ""
        }

        if let imageColorGrayscaleText = builderArgs?["ImageColorGrayscaleText"] {
            builder.klippaButtonTexts.imageColorGrayscaleText = imageColorGrayscaleText  as? String ?? ""
        }

        if let imageColorEnhancedText = builderArgs?["ImageColorEnhancedText"] {
            builder.klippaButtonTexts.imageColorEnhancedText = imageColorEnhancedText  as? String ?? ""
        }

        if let imageLimitReachedMessage = builderArgs?["ImageLimitReachedMessage"] {
            builder.klippaMessages.imageLimitReachedMessage = imageLimitReachedMessage  as? String ?? ""
        }

        if let deleteButtonText = builderArgs?["DeleteButtonText"] {
            builder.klippaButtonTexts.deleteButtonText = deleteButtonText  as? String ?? ""
        }

        if let retakeButtonText = builderArgs?["RetakeButtonText"] {
            builder.klippaButtonTexts.retakeButtonText = retakeButtonText  as? String ?? ""
        }

        if let cancelButtonText = builderArgs?["CancelButtonText"] {
            builder.klippaButtonTexts.cancelButtonText = cancelButtonText  as? String ?? ""
        }

        if let cancelAndDeleteImagesButtonText = builderArgs?["CancelAndDeleteImagesButtonText"] {
            builder.klippaButtonTexts.cancelAndDeleteImagesButtonText = cancelAndDeleteImagesButtonText  as? String ?? ""
        }

        if let cancelConfirmationMessage = builderArgs?["CancelConfirmationMessage"] {
            builder.klippaMessages.cancelConfirmationMessage = cancelConfirmationMessage  as? String ?? ""
        }

        if let shouldGoToReviewScreenWhenImageLimitReached = builderArgs?["ShouldGoToReviewScreenWhenImageLimitReached"] {
            builder.klippaMenu.shouldGoToReviewScreenWhenImageLimitReached = shouldGoToReviewScreenWhenImageLimitReached as? Bool ?? false
        }

        if let userCanRotateImage = builderArgs?["UserCanRotateImage"] {
            builder.klippaMenu.userCanRotateImage = userCanRotateImage as? Bool ?? true
        }

        if let userCanCropManually = builderArgs?["UserCanCropManually"] {
            builder.klippaMenu.userCanCropManually = userCanCropManually as? Bool ?? true
        }

        if let userCanChangeColorSetting = builderArgs?["UserCanChangeColorSetting"] {
            builder.klippaMenu.userCanChangeColorSetting = userCanChangeColorSetting as? Bool ?? true
        }

        if let primaryColor = builderArgs?["PrimaryColor"] {
            let color = primaryColor as? String ?? ""
            builder.klippaColors.primaryColor = hexColorToUIColor(hex: color)
        }

        if let accentColor = builderArgs?["AccentColor"] {
            let color = accentColor as? String ?? ""
            builder.klippaColors.accentColor = hexColorToUIColor(hex: color)
        }

        if let overlayColor = builderArgs?["OverlayColor"] {
            let color = overlayColor as? String ?? ""
            builder.klippaColors.overlayColor = hexColorToUIColor(hex: color)
        }

        if let overlayColorAlpha = builderArgs?["OverlayColorAlpha"] {
            builder.klippaColors.overlayColorAlpha = overlayColorAlpha as? CGFloat ?? 0.75
        }

        if let warningBackgroundColor = builderArgs?["WarningBackgroundColor"] {
            let color = warningBackgroundColor as? String ?? ""
            builder.klippaColors.warningBackgroundColor = hexColorToUIColor(hex: color)
        }

        if let warningTextColor = builderArgs?["WarningTextColor"] {
            let color = warningTextColor as? String ?? ""
            builder.klippaColors.warningTextColor = hexColorToUIColor(hex: color)
        }

        if let iconEnabledColor = builderArgs?["IconEnabledColor"] {
            let color = iconEnabledColor as? String ?? ""
            builder.klippaColors.iconEnabledColor = hexColorToUIColor(hex: color)
        }

        if let iconDisabledColor = builderArgs?["IconDisabledColor"] {
            let color = iconDisabledColor as? String ?? ""
            builder.klippaColors.iconDisabledColor = hexColorToUIColor(hex: color)
        }

        if let reviewIconColor = builderArgs?["ReviewIconColor"] {
            let color = reviewIconColor as? String ?? ""
            builder.klippaColors.reviewIconColor = hexColorToUIColor(hex: color)
        }

        if let isViewFinderEnabled = builderArgs?["IsViewFinderEnabled"] {
            builder.klippaMenu.isViewFinderEnabled = isViewFinderEnabled as? Bool ?? true
        }

        if let imageMovingSensitivity = builderArgs?["ImageMovingSensitivityiOS"] {
            builder.klippaImageAttributes.imageMovingSensitivity = imageMovingSensitivity as? CGFloat ?? 200
        }

        if let storeImagesToCameraRoll = builderArgs?["StoreImagesToCameraRoll"] {
            builder.klippaImageAttributes.storeImagesToCameraRoll = storeImagesToCameraRoll as? Bool ?? true
        }

        if let imageLimit = builderArgs?["ImageLimit"] {
            builder.klippaImageAttributes.imageLimit = imageLimit as? Int ?? 0
        }

        let modelFile = builderArgs?["Model.fileName"] as? String ?? ""

        let modelLabels = builderArgs?["Model.modelLabels"] as? String ?? ""

        if modelFile != "" && modelLabels != "" {
            builder.klippaObjectDetectionModel.modelFile = modelFile
            builder.klippaObjectDetectionModel.modelLabels = modelLabels
            builder.klippaObjectDetectionModel.runWithModel = true
        }

        resultHandler = result

        let viewController = builder.build()
        let rootViewController = UIApplication.shared.windows.last!.rootViewController!
        rootViewController.present(viewController, animated:true, completion:nil)
    }

    public func klippaScannerDidFailWithError(error: Error) {
        print("didFailWithError");
        switch error {
        case let licenseError as KlippaScannerLicenseError:
            resultHandler!(FlutterError.init(code: E_MISSING_LICENSE, message: licenseError.localizedDescription, details: nil))
        default:
            resultHandler!(FlutterError.init(code: E_MISSING_LICENSE, message: error.localizedDescription, details: nil))
        }
        resultHandler = nil;
    }

    public func klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
        var images: [[String: String]] = []
        for image in result.images {
            let imageDict = ["Filepath" : image.path]
            images.append(imageDict)
        }

        let resultDict = [
            "Images" : images,
            "MultipleDocuments" : result.multipleDocumentsModeEnabled,
            "Crop": result.cropEnabled,
            "TimerEnabled" : result.timerEnabled
        ] as [String : Any]

        resultHandler!(resultDict)
        resultHandler = nil
    }

    public func klippaScannerDidCancel() {
        print("imageScannerControllerDidCancel");
        resultHandler!(FlutterError.init(code: E_CANCELED, message: "The user canceled", details: nil))
        resultHandler = nil;
    }

    private func hexColorToUIColor(hex: String) -> UIColor {
        let r, g, b, a: CGFloat

        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x000000ff) / 255

                return UIColor.init(red: r, green: g, blue: b, alpha: a)
            }
        }

        return UIColor.white
    }


}
