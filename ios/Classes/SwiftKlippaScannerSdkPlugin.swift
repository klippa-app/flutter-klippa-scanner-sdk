import Flutter
import UIKit
import KlippaScanner

public class SwiftKlippaScannerSdkPlugin: NSObject, FlutterPlugin, ImageScannerControllerDelegate {
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

        if let license = builderArgs?["License"] {
            KlippaScanner.setup.set(license: license as? String ?? "")
        } else {
            result(FlutterError.init(code: E_MISSING_LICENSE, message: "Missing license", details: nil))
            return
        }
        
        if let allowMultipleDocumentsMode = builderArgs?["AllowMultipleDocuments"] {
            KlippaScanner.setup.allowMultipleDocumentsMode = allowMultipleDocumentsMode as? Bool ?? true
        }
        
        if let isMultipleDocumentsModeEnabled = builderArgs?["DefaultMultipleDocuments"] {
            KlippaScanner.setup.isMultipleDocumentsModeEnabled = isMultipleDocumentsModeEnabled as? Bool ?? false
        }
        
        if let isCropEnabled = builderArgs?["DefaultCrop"] {
            KlippaScanner.setup.isCropEnabled = isCropEnabled as? Bool ?? true
        }
        
        if let moveCloserMessage = builderArgs?["MoveCloserMessage"] {
            KlippaScanner.setup.moveCloserMessage = moveCloserMessage as? String ?? ""
        }
        
        if let imageMovingMessage = builderArgs?["ImageMovingMessage"] {
            KlippaScanner.setup.imageMovingMessage = imageMovingMessage as? String ?? ""
        }
        
        if let imageMaxWidth = builderArgs?["ImageMaxWidth"] {
            KlippaScanner.setup.imageMaxWidth = imageMaxWidth as? CGFloat ?? 0
        }
        
        if let imageMaxHeight = builderArgs?["ImageMaxHeight"] {
            KlippaScanner.setup.imageMaxHeight = imageMaxHeight as? CGFloat ?? 0
        }
        
        if let imageMaxQuality = builderArgs?["ImageMaxQuality"] {
            KlippaScanner.setup.imageMaxQuality = imageMaxQuality as? CGFloat ?? 100
        }
        
        if let previewDuration = builderArgs?["PreviewDuration"] {
            KlippaScanner.setup.previewDuration = previewDuration as? Double ?? 0
        }

        if let isTimerAllowed = builderArgs?["Timer.allowed"] {
            KlippaScanner.setup.allowTimer = isTimerAllowed as? Bool ?? false
        }

        if let isTimerEnabled = builderArgs?["Timer.enabled"] {
            KlippaScanner.setup.isTimerEnabled = isTimerEnabled as? Bool ?? false
        }
        
        if let timerDuration = builderArgs?["Timer.duration"] {
            KlippaScanner.setup.timerDuration = timerDuration as? Double ?? 0
        }
        
        let width = builderArgs?["CropPadding.width"] as? Int ?? 0
        let height = builderArgs?["CropPadding.height"] as? Int ?? 0
        
        KlippaScanner.setup.set(cropPadding: CGSize(width:  width, height: height))
        
        if let successPreviewDuration = builderArgs?["Success.previewDuration"] {
            KlippaScanner.setup.successPreviewDuration = successPreviewDuration as? Double ?? 0
        }
        
        if let successMessage = builderArgs?["Success.message"] {
            KlippaScanner.setup.successMessage = successMessage as? String ?? ""
        }
        
        if let allowShutterButton = builderArgs?["ShutterButton.allowShutterButton"] {
            if let hideShutterButton = builderArgs?["ShutterButton.hideShutterButton"] {
               KlippaScanner.setup.set(allowShutterButton: allowShutterButton as? Bool ?? true, hideShutterButton: hideShutterButton as? Bool ?? false)
            }
        }
        
        if let imageTooBrightMessage = builderArgs?["ImageTooBrightMessage"] {
            KlippaScanner.setup.imageTooBrightMessage = imageTooBrightMessage as? String ?? ""
        }
        
        if let imageTooDarkMessage = builderArgs?["ImageTooDarkMessage"] {
            KlippaScanner.setup.imageTooDarkMessage = imageTooDarkMessage  as? String ?? ""
        }

        if let imageLimitReachedMessage = builderArgs?["ImageLimitReachedMessage"] {
            KlippaScanner.setup.imageLimitReachedMessage = imageLimitReachedMessage  as? String ?? ""
        }
        
        if let primaryColor = builderArgs?["PrimaryColor"] {
            let color = primaryColor as? String ?? ""
            KlippaScanner.setup.primaryColor = hexColorToUIColor(hex: color)
        }
        
        if let accentColor = builderArgs?["AccentColor"] {
            let color = accentColor as? String ?? ""
            KlippaScanner.setup.accentColor = hexColorToUIColor(hex: color)
        }
        
        if let overlayColor = builderArgs?["OverlayColor"] {
            let color = overlayColor as? String ?? ""
            KlippaScanner.setup.overlayColor = hexColorToUIColor(hex: color)
        }

        if let overlayColorAlpha = builderArgs?["OverlayColorAlpha"] {
            KlippaScanner.setup.overlayColorAlpha = overlayColorAlpha as? CGFloat ?? 0.75
        }
        
        if let warningBackgroundColor = builderArgs?["WarningBackgroundColor"] {
            let color = warningBackgroundColor as? String ?? ""
            KlippaScanner.setup.warningBackgroundColor = hexColorToUIColor(hex: color)
        }
        
        if let warningTextColor = builderArgs?["WarningTextColor"] {
            let color = warningTextColor as? String ?? ""
            KlippaScanner.setup.warningTextColor = hexColorToUIColor(hex: color)
        }
        
        if let iconEnabledColor = builderArgs?["IconEnabledColor"] {
            let color = iconEnabledColor as? String ?? ""
            KlippaScanner.setup.iconEnabledColor = hexColorToUIColor(hex: color)
        }
        
        if let iconDisabledColor = builderArgs?["IconDisabledColor"] {
            let color = iconDisabledColor as? String ?? ""
            KlippaScanner.setup.iconDisabledColor = hexColorToUIColor(hex: color)
        }
        
        if let reviewIconColor = builderArgs?["ReviewIconColor"] {
            let color = reviewIconColor as? String ?? ""
            KlippaScanner.setup.reviewIconColor = hexColorToUIColor(hex: color)
        }
        
        if let isViewFinderEnabled = builderArgs?["IsViewFinderEnabled"] {
            KlippaScanner.setup.isViewFinderEnabled = isViewFinderEnabled as? Bool ?? true
        }
        
        if let imageMovingSensitivity = builderArgs?["ImageMovingSensitivityiOS"] {
            KlippaScanner.setup.imageMovingSensitivity = imageMovingSensitivity as? CGFloat ?? 200
        }
        
        if let storeImagesToCameraRoll = builderArgs?["StoreImagesToCameraRoll"] {
            KlippaScanner.setup.storeImagesToCameraRoll = storeImagesToCameraRoll as? Bool ?? true
        }

        if let imageLimit = builderArgs?["ImageLimit"] {
            KlippaScanner.setup.imageLimit = imageLimit as? Int ?? 0
        }

        let rootViewController = UIApplication.shared.windows.last!.rootViewController!

        let modelFile = builderArgs?["Model.fileName"] as? String ?? ""

        let modelLabels = builderArgs?["Model.modelLabels"] as? String ?? ""

        if modelFile != "" && modelLabels != "" {
            KlippaScanner.setup.modelFile = modelFile
            KlippaScanner.setup.modelLabels = modelLabels
            KlippaScanner.setup.runWithModel = true
        }

        resultHandler = result

        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        scannerViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(scannerViewController, animated: false)
    }

    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print("didFailWithError");
        switch error {
        case let licenseError as LicenseError:
            resultHandler!(FlutterError.init(code: E_MISSING_LICENSE, message: licenseError.localizedDescription, details: nil))
        default:
            resultHandler!(FlutterError.init(code: E_MISSING_LICENSE, message: error.localizedDescription, details: nil))
        }
        resultHandler = nil;
        scanner.dismiss(animated: true, completion: nil)
    }

    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResult result: ImageScannerResult) {
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

    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        print("imageScannerControllerDidCancel");
        resultHandler!(FlutterError.init(code: E_CANCELED, message: "The user canceled", details: nil))
        resultHandler = nil;
        scanner.dismiss(animated: true, completion: nil)
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
