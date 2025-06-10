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
        switch call.method {
        case "startSession":
            startSession(call, result: result)
        case "purge":
            purge(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func purge(result: @escaping FlutterResult) {
        KlippaScannerStorage.purge()
        result(nil)
    }

    private func startSession(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments else {
            result(FlutterError.init(code: E_UNKNOWN_ERROR, message: "Unknown error", details: nil))
            return
        }

        let builderArgs = args as? [String: Any]

        guard let license = builderArgs?["License"] as? String else {
            result(FlutterError.init(code: E_MISSING_LICENSE, message: "Missing license", details: nil))
            return
        }

        let builder = KlippaScannerBuilder(builderDelegate: self, license: license)

        if let isCropEnabled = builderArgs?["DefaultCrop"] as? Bool {
            builder.klippaMenu.isCropEnabled = isCropEnabled
        }

        if let moveCloserMessage = builderArgs?["MoveCloserMessage"] as? String {
            builder.klippaMessages.moveCloserMessage = moveCloserMessage
        }

        if let imageMovingMessage = builderArgs?["ImageMovingMessage"] as? String {
            builder.klippaMessages.imageMovingMessage = imageMovingMessage
        }

        if let orientationWarningMessage = builderArgs?["OrientationWarningMessage"] as? String {
            builder.klippaMessages.orientationWarningMessage = orientationWarningMessage
        }

        if let imageMaxWidth = builderArgs?["ImageMaxWidth"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxWidth = imageMaxWidth
        }

        if let imageMaxHeight = builderArgs?["ImageMaxHeight"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxHeight = imageMaxHeight
        }

        if let imageMaxQuality = builderArgs?["ImageMaxQuality"] as? CGFloat {
            builder.klippaImageAttributes.imageMaxQuality = imageMaxQuality
        }

        if let previewDuration = builderArgs?["PreviewDuration"] as? Double {
            builder.klippaDurations.previewDuration = previewDuration
        }

        if let isTimerAllowed = builderArgs?["Timer.allowed"] as? Bool {
            builder.klippaMenu.allowTimer = isTimerAllowed
        }

        if let isTimerEnabled = builderArgs?["Timer.enabled"] as? Bool {
            builder.klippaMenu.isTimerEnabled = isTimerEnabled
        }

        if let timerDuration = builderArgs?["Timer.duration"] as? Double {
            builder.klippaDurations.timerDuration = timerDuration
        }

        if let width = builderArgs?["CropPadding.width"] as? Double {
            builder.klippaImageAttributes.cropPadding.width = width
        }

        if let height = builderArgs?["CropPadding.height"] as? Double {
            builder.klippaImageAttributes.cropPadding.height = height
        }


        if let successPreviewDuration = builderArgs?["Success.previewDuration"] as? Double {
            builder.klippaDurations.successPreviewDuration = successPreviewDuration
        }

        if let successMessage = builderArgs?["Success.message"] as? String {
            builder.klippaMessages.successMessage = successMessage
        }

        if let allowShutterButton = builderArgs?["ShutterButton.allowShutterButton"] as? Bool, let hideShutterButton = builderArgs?["ShutterButton.hideShutterButton"] as? Bool {
            builder.klippaShutterbutton.allowShutterButton = allowShutterButton
            builder.klippaShutterbutton.hideShutterButton = hideShutterButton
        }

        if let imageTooBrightMessage = builderArgs?["ImageTooBrightMessage"] as? String {
            builder.klippaMessages.imageTooBrightMessage = imageTooBrightMessage
        }

        if let imageTooDarkMessage = builderArgs?["ImageTooDarkMessage"] as? String {
            builder.klippaMessages.imageTooDarkMessage = imageTooDarkMessage
        }

        if let defaultColor = builderArgs?["DefaultColor"] as? String {
            switch defaultColor {
            case "grayscale":
                builder.klippaColors.imageColor = .grayscale
            case "enhanced":
                builder.klippaColors.imageColor = .enhanced
            default:
                builder.klippaColors.imageColor = .original
            }
        }

        if let imageColorOriginalText = builderArgs?["ImageColorOriginalText"] as? String {
            builder.klippaButtonTexts.imageColorOriginalText = imageColorOriginalText
        }

        if let imageColorGrayscaleText = builderArgs?["ImageColorGrayscaleText"] as? String {
            builder.klippaButtonTexts.imageColorGrayscaleText = imageColorGrayscaleText
        }

        if let imageColorEnhancedText = builderArgs?["ImageColorEnhancedText"] as? String {
            builder.klippaButtonTexts.imageColorEnhancedText = imageColorEnhancedText
        }

        if let continueButtonText = builderArgs?["ContinueButtonText"] as? String {
            builder.klippaButtonTexts.continueButtonText = continueButtonText
        }

        if let imageLimitReachedMessage = builderArgs?["ImageLimitReachedMessage"] as? String {
            builder.klippaMessages.imageLimitReachedMessage = imageLimitReachedMessage
        }

        if let deleteButtonText = builderArgs?["DeleteButtonText"] as? String {
            builder.klippaButtonTexts.deleteButtonText = deleteButtonText
        }

        if let retakeButtonText = builderArgs?["RetakeButtonText"] as? String {
            builder.klippaButtonTexts.retakeButtonText = retakeButtonText
        }

        if let cancelButtonText = builderArgs?["CancelButtonText"] as? String {
            builder.klippaButtonTexts.cancelButtonText = cancelButtonText
        }

        if let cancelAndDeleteImagesButtonText = builderArgs?["CancelAndDeleteImagesButtonText"] as? String {
            builder.klippaButtonTexts.cancelAndDeleteImagesButtonText = cancelAndDeleteImagesButtonText
        }

        if let cropEditButtonText = builderArgs?["CropEditButtonText"] as? String {
            builder.klippaButtonTexts.cropEditButtonText = cropEditButtonText
        }

        if let filterEditButtonText = builderArgs?["FilterEditButtonText"] as? String {
            builder.klippaButtonTexts.filterEditButtonText = filterEditButtonText
        }

        if let rotateEditButtonText = builderArgs?["RotateEditButtonText"] as? String {
            builder.klippaButtonTexts.rotateEditButtonText = rotateEditButtonText
        }

        if let deleteEditButtonText = builderArgs?["DeleteEditButtonText"] as? String {
            builder.klippaButtonTexts.deleteEditButtonText = deleteEditButtonText
        }

        if let cancelCropButtonText = builderArgs?["CancelCropButtonText"] as? String {
            builder.klippaButtonTexts.cancelCropButtonText = cancelCropButtonText
        }

        if let expandCropButtonText = builderArgs?["ExpandCropButtonText"] as? String {
            builder.klippaButtonTexts.expandCropButtonText = expandCropButtonText
        }

        if let saveCropButtonText = builderArgs?["SaveCropButtonText"] as? String {
            builder.klippaButtonTexts.saveCropButtonText = saveCropButtonText
        }

        if let cancelConfirmationMessage = builderArgs?["CancelConfirmationMessage"] as? String {
            builder.klippaMessages.cancelConfirmationMessage = cancelConfirmationMessage
        }

        if let segmentedModeImageCountMessage = builderArgs?["SegmentedModeImageCountMessage"] as? String {
            builder.klippaMessages.segmentedModeImageCountMessage = segmentedModeImageCountMessage
        }

        if let shouldGoToReviewScreenWhenImageLimitReached = builderArgs?["ShouldGoToReviewScreenWhenImageLimitReached"] as? Bool {
            builder.klippaMenu.shouldGoToReviewScreenWhenImageLimitReached = shouldGoToReviewScreenWhenImageLimitReached
        }

        if let userShouldAcceptResultToContinue = builderArgs?["UserShouldAcceptResultToContinue"] as? Bool {
            builder.klippaMenu.userShouldAcceptResultToContinue = userShouldAcceptResultToContinue
        }

        if let userCanRotateImage = builderArgs?["UserCanRotateImage"] as? Bool {
            builder.klippaMenu.userCanRotateImage = userCanRotateImage
        }

        if let userCanCropManually = builderArgs?["UserCanCropManually"] as? Bool {
            builder.klippaMenu.userCanCropManually = userCanCropManually
        }

        if let userCanChangeColorSetting = builderArgs?["UserCanChangeColorSetting"] as? Bool {
            builder.klippaMenu.userCanChangeColorSetting = userCanChangeColorSetting
        }

        if let primaryColor = builderArgs?["PrimaryColor"] as? String {
            builder.klippaColors.primaryColor = hexColorToUIColor(hex: primaryColor)
        }

        if let accentColor = builderArgs?["AccentColor"] as? String {
            builder.klippaColors.accentColor = hexColorToUIColor(hex: accentColor)
        }

        if let secondaryColor = builderArgs?["SecondaryColor"] as? String {
            builder.klippaColors.secondaryColor = hexColorToUIColor(hex: secondaryColor)
        }

        if let overlayColorAlpha = builderArgs?["OverlayColorAlpha"] as? CGFloat {
            builder.klippaColors.overlayColorAlpha = overlayColorAlpha
        }

        if let warningBackgroundColor = builderArgs?["WarningBackgroundColor"] as? String {
            builder.klippaColors.warningBackgroundColor = hexColorToUIColor(hex: warningBackgroundColor)
        }

        if let warningTextColor = builderArgs?["WarningTextColor"] as? String {
            builder.klippaColors.warningTextColor = hexColorToUIColor(hex: warningTextColor)
        }

        if let iconEnabledColor = builderArgs?["IconEnabledColor"] as? String {
            builder.klippaColors.iconEnabledColor = hexColorToUIColor(hex: iconEnabledColor)
        }

        if let iconDisabledColor = builderArgs?["IconDisabledColor"] as? String {
            builder.klippaColors.iconDisabledColor = hexColorToUIColor(hex: iconDisabledColor)
        }

        if let buttonWithIconForegroundColor = builderArgs?["ButtonWithIconForegroundColor"] as? String {
            builder.klippaColors.buttonWithIconForegroundColor = hexColorToUIColor(hex: buttonWithIconForegroundColor)
        }

        if let buttonWithIconBackgroundColor = builderArgs?["ButtonWithIconBackgroundColor"] as? String {
            builder.klippaColors.buttonWithIconBackgroundColor = hexColorToUIColor(hex: buttonWithIconBackgroundColor)
        }

        if let primaryActionForegroundColor = builderArgs?["PrimaryActionForegroundColor"] as? String {
            builder.klippaColors.primaryActionForegroundColor = hexColorToUIColor(hex: primaryActionForegroundColor)
        }

        if let primaryActionBackgroundColor = builderArgs?["PrimaryActionBackgroundColor"] as? String {
            builder.klippaColors.primaryActionBackgroundColor = hexColorToUIColor(hex: primaryActionBackgroundColor)
        }

        if let isViewFinderEnabled = builderArgs?["IsViewFinderEnabled"] as? Bool {
            builder.klippaMenu.isViewFinderEnabled = isViewFinderEnabled
        }

        if let imageMovingSensitivity = builderArgs?["ImageMovingSensitivityiOS"] as? CGFloat {
            builder.klippaImageAttributes.imageMovingSensitivity = imageMovingSensitivity
        }

        if let storeImagesToCameraRoll = builderArgs?["StoreImagesToCameraRoll"] as? Bool {
            builder.klippaImageAttributes.storeImagesToCameraRoll = storeImagesToCameraRoll
        }

        if let userCanPickMediaFromStorage = builderArgs?["UserCanPickMediaFromStorage"] as? Bool {
            builder.klippaMenu.userCanPickMediaFromStorage = userCanPickMediaFromStorage
        }

        if let shouldGoToReviewScreenOnFinishPressed = builderArgs?["ShouldGoToReviewScreenOnFinishPressed"] as? Bool {
            builder.klippaMenu.shouldGoToReviewScreenOnFinishPressed = shouldGoToReviewScreenOnFinishPressed
        }


        if let outputFormat = builderArgs?["OutputFormat"] as? String {
            switch outputFormat {
            case "jpeg":
                builder.klippaImageAttributes.outputFormat = .jpeg
            case "pdfSingle":
                builder.klippaImageAttributes.outputFormat = .pdfSingle
            case "pdfMerged":
                builder.klippaImageAttributes.outputFormat = .pdfMerged
            default:
                builder.klippaImageAttributes.outputFormat = .jpeg
            }
        }

        if let performOnDeviceOCR = builderArgs?["PerformOnDeviceOCR"] as? Bool {
            builder.klippaImageAttributes.performOnDeviceOCR = performOnDeviceOCR
        }

        if let brightnessLowerThreshold = builderArgs?["BrightnessLowerThreshold"] as? Double {
            builder.klippaImageAttributes.brightnessLowerThreshold = brightnessLowerThreshold
        }

        if let brightnessUpperThreshold = builderArgs?["BrightnessUpperThreshold"] as? Double {
            builder.klippaImageAttributes.brightnessUpperThreshold = brightnessUpperThreshold
        }

        var modes: [KlippaDocumentMode] = []

        if let cameraModeSingle = builderArgs?["CameraModeSingle"] as? Dictionary<String, String?> {
            let singleDocumentMode = KlippaSingleDocumentMode()
            if let name = cameraModeSingle["name"] as? String {
                singleDocumentMode.name = name
            }

            if let message = cameraModeSingle["message"] as? String ?? singleDocumentMode.instructions?.message {
                let image = cameraModeSingle["image"] as? String
                singleDocumentMode.instructions = Instructions(
                    title: singleDocumentMode.name,
                    message: message,
                    image: image ?? KlippaSingleDocumentMode.image
                )
            }

            modes.append(singleDocumentMode)
        }

        if let cameraModeMulti = builderArgs?["CameraModeMulti"] as? Dictionary<String, String?> {
            let multiDocumentMode = KlippaMultipleDocumentMode()
            if let name = cameraModeMulti["name"] as? String {
                multiDocumentMode.name = name
            }

            if let message = cameraModeMulti["message"] as? String ?? multiDocumentMode.instructions?.message {
                let image = cameraModeMulti["image"] as? String
                multiDocumentMode.instructions = Instructions(
                    title: multiDocumentMode.name,
                    message: message,
                    image: image ?? KlippaMultipleDocumentMode.image
                )
            }

            modes.append(multiDocumentMode)
        }

        if let cameraModeSegmented = builderArgs?["CameraModeSegmented"] as? Dictionary<String, String?> {
            let segmentedDocumentMode = KlippaSegmentedDocumentMode()
            if let name = cameraModeSegmented["name"] as? String {
                segmentedDocumentMode.name = name
            }

            if let message = cameraModeSegmented["message"] as? String ?? segmentedDocumentMode.instructions?.message {
                let image = cameraModeSegmented["image"] as? String
                segmentedDocumentMode.instructions = Instructions(
                    title: segmentedDocumentMode.name,
                    message: message,
                    image: image ?? KlippaSegmentedDocumentMode.image
                )
            }

            modes.append(segmentedDocumentMode)
        }

        if !modes.isEmpty {
            var index = 0
            if let setIndex = builderArgs?["StartingIndex"] as? Double {
                index = Int(setIndex)
            }

            let cameraModes = KlippaCameraModes(
                modes: modes,
                startingIndex: index
            )

            builder.klippaCameraModes = cameraModes
        }


        if let imageLimit = builderArgs?["ImageLimit"] as? Int {
            builder.klippaImageAttributes.imageLimit = imageLimit
        }

        if let modelFile = builderArgs?["Model.fileName"] as? String, let modelLabels = builderArgs?["Model.modelLabels"] as? String {
            builder.klippaObjectDetectionModel = KlippaObjectDetectionModel(
                modelFile: modelFile,
                modelLabels: modelLabels
            )
        }

        resultHandler = result

        let viewControllerResult = builder.build()
        let rootViewController = UIApplication.shared.windows.last!.rootViewController!

        switch viewControllerResult {
        case .success(let controller):
            controller.modalPresentationStyle = .fullScreen
            rootViewController.present(controller, animated:true, completion:nil)
        case .failure(let err):
            result(FlutterError.init(code: E_FAILED_TO_SHOW_SESSION, message: "error: \(err)", details: nil))
        }
    }

    public func klippaScannerDidFailWithError(error: Error) {
        resultHandler?(FlutterError.init(code: E_CANCELED, message: "Scanner canceled with error: \(error.localizedDescription)", details: nil))
        resultHandler = nil;
    }

    public func klippaScannerDidFinishScanningWithResult(result: KlippaScannerResult) {
        var images: [[String: String]] = []
        for image in result.results {
            let imageDict = ["Filepath" : image.path]
            images.append(imageDict)
        }

        let singleDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.singleDocument.name] ?? false
        let multiDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.multipleDocument.name] ?? false
        let segmentedDocumentModeInstructionsDismissed = result.dismissedInstructions[DocModeType.segmentedDocument.name] ?? false

        let resultDict = [
            "Images" : images,
            "Crop": result.cropEnabled,
            "TimerEnabled" : result.timerEnabled,
            "SingleDocumentModeInstructionsDismissed": singleDocumentModeInstructionsDismissed,
            "MultiDocumentModeInstructionsDismissed": multiDocumentModeInstructionsDismissed,
            "SegmentedDocumentModeInstructionsDismissed": segmentedDocumentModeInstructionsDismissed
        ] as [String : Any]

        resultHandler?(resultDict)
        resultHandler = nil
    }

    public func klippaScannerDidCancel() {
        resultHandler?(FlutterError.init(code: E_CANCELED, message: "The user canceled", details: nil))
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
