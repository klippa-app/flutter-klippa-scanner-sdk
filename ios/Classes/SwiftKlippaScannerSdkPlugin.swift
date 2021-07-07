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
            KlippaScanner.setup.set(license: license as! String)
        } else {
            result(FlutterError.init(code: E_MISSING_LICENSE, message: "Missing license", details: nil))
            return
        }
        let rootViewController: UIViewController! = UIApplication.shared.keyWindow?.rootViewController
        let scannerViewController = ImageScannerController()
        scannerViewController.imageScannerDelegate = self
        scannerViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(scannerViewController, animated: false)
    }

    public func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print("didFailWithError");
        switch error {
        case let licenseError as LicenseError:
            print("Got licensing error from SDK: \(licenseError.localizedDescription)")
        default:
            print(error)
        }
    }

    public func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResult result: ImageScannerResult) {
        print("didFinishScanningWithResults");
        print("multipleDocumentsModeEnabled \(result.multipleDocumentsModeEnabled)")
        print("Scanned \(result.images.count) images")
        if let last = result.images.last {
            if let image = try? KlippaScannerStorage.retrieve(path: last.path, from: .documents, as: UIImage.self) {
                // We get back an UIImage from this helper method.
                print(image)
            }
        }
    }

    public func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        print("imageScannerControllerDidCancel");
        scanner.dismiss(animated: true, completion: nil)
    }
}
