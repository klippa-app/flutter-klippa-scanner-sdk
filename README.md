# flutter-klippa-scanner-sdk

[![Dart version][dart-version]][dart-url]
[![Build Status][build-status]][build-url]

[build-status]:https://github.com/klippa-app/flutter-klippa-scanner-sdk/workflows/Build%20CI/badge.svg
[build-url]:https://github.com/klippa-app/nativescript-http/actions
[dart-version]:https://img.shields.io/pub/v/klippa_scanner_sdk.svg
[dart-url]:https://pub.dev/packages/klippa_scanner_sdk


## SDK usage
Please be aware you need to have a license to use this SDK.
If you would like to use our scanner, please contact us [here](https://www.klippa.com/en/ocr/ocr-sdk/)

## Getting started
### Android
Edit the file `android/build.gradle`, add the Klippa Maven repository:

```groovy
allprojects {
    repositories {
        // ... other repositories

        maven {
            credentials {
                username "{your-username}"
                password "{your-password}"
            }
            url "https://custom-ocr.klippa.com/sdk/android/maven"
        }
    }
}
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

### iOS

Edit the file `ios/Podfile`, add the Klippa CocoaPod:
```
platform :ios, '11.0'
ENV['KLIPPA_SCANNER_SDK_USERNAME'] = '{your-username}'
ENV['KLIPPA_SCANNER_SDK_PASSWORD'] = '{your-password}'

// Edit the Runner config to add the pod:

target 'Runner' do
    // ... other instructions
    
    // Add this below flutter_install_all_ios_pods    
    if "#{ENV['KLIPPA_SCANNER_SDK_URL']}" == ""
        ENV['KLIPPA_SCANNER_SDK_URL'] = File.read(File.join(File.dirname(File.realpath(__FILE__)), '.symlinks', 'plugins', 'klippa_scanner_sdk', 'ios', '.sdk_repo')).strip
    end

    if "#{ENV['KLIPPA_SCANNER_SDK_VERSION']}" == ""
        ENV['KLIPPA_SCANNER_SDK_VERSION'] = File.read(File.join(File.dirname(File.realpath(__FILE__)), '.symlinks', 'plugins', 'klippa_scanner_sdk', 'ios', '.sdk_version')).strip
    end

    pod 'Klippa-Scanner', podspec: "#{ENV['KLIPPA_SCANNER_SDK_URL']}/#{ENV['KLIPPA_SCANNER_SDK_USERNAME']}/#{ENV['KLIPPA_SCANNER_SDK_PASSWORD']}/KlippaScanner/#{ENV['KLIPPA_SCANNER_SDK_VERSION']}.podspec"
end
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

Edit the file `ios/{project-name}/Info.plist` and add the `NSCameraUsageDescription` value:
```
...
<key>NSCameraUsageDescription</key>
<string>Access to your camera is needed to photograph documents.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Access to your photo library is used to save the images of documents.</string>
...
```

### Flutter

Add `klippa_scanner_sdk` as a dependency in your pubspec.yaml file.

## Usage

```dart
import 'package:klippa_scanner_sdk/klippa_scanner_sdk.dart';

var config = CameraConfig();

try {
  var result = await KlippaScannerSdk.startSession(config, '{insert-license-here');
} on PlatformException catch (e) {
  print('Failed to start session ' + e.toString());
}
```

The reject reason object has a code and a message, the used codes are:

The reject reason object has a code and a message, the used codes are:
- E_ACTIVITY_DOES_NOT_EXIST (Android only)
- E_FAILED_TO_SHOW_SESSION (Android only)
- E_MISSING_LICENSE
- E_CANCELED
- E_UNKNOWN_ERROR

## How to use a specific version of the SDK?

### Android

Edit the file `android/build.gradle`, add the following:

```maven
allprojects {
  // ... other definitions
  project.ext {
      klippaScannerVersion = "{version}"
  }
}
```

Replace the `{version` value with the version you want to use.

If you want to change the repository:

Edit the file `android/key.properties`, add the sdk repository URL:

```
klippa.scanner.sdk.url={repository-url}
```

Replace `{repository-url` with the URL that you want to use.

### iOS

Edit the file `ios/Podfile`, add the followingline below the username/password if you want to change the version:
```
ENV['KLIPPA_SCANNER_SDK_VERSION'] = '{version}'
```

replace `{version}` with the version you want to use.

If you want to change the repository:

Edit the file `ios/Podfile` add the following line below the username/password if you want to change the URL:

```
ENV['KLIPPA_SCANNER_SDK_URL'] = '{repository-url}'
```

Replace `{repository-url}` with the URL that you want to use.

## How to change the setup of the SDK:

## General

```dart
// Whether to show the icon to enable "multi-document-mode"
config.allowMultipleDocuments = true;

// Whether the "multi-document-mode" should be enabled by default.
config.defaultMultipleDocuments = true;

// Ability to disable/hide the shutter button (only works when a model is supplied as well).
config.shutterButton.allowshutterButton = true;
config.shutterButton.hideShutterbutton = false;

// Whether the crop mode (auto edge detection) should be enabled by default.
config.defaultCrop = true;

// Define the max resolution of the output file. It’s possible to set only one of these values. We will make sure the picture fits in the given resolution. We will also keep the aspect ratio of the image. Default is max resolution of camera.
config.imageMaxWidth = 1920;
config.imageMaxHeight = 1080;

// Set the output quality (between 0-100) of the jpg encoder. Default is 100.
config.imageMaxQuality = 95;

// The warning message when someone should move closer to a document, should be a string.
config.moveCloserMessage = "Move closer to the document";

// The warning message when the camera preview has to much motion to be able to automatically take a photo.
config.imageMovingMessage = "Too much movement";

// If you would like to use a custom model for object detection. Model + labels file should be packaged in your bundle.
config.model.fileName = "model";
config.model.modelLabels = "labelmap";

// If you would like to enable automatic capturing of images.
config.timer.enabled = true;
config.timer.duration = 1.0;

// To add extra horizontal and / or vertical padding to the cropped image.
config.cropPadding = Dimensions(100, 100);

// After capture, show a checkmark preview with this success message, instead of a preview of the image.
config.success.previewDuration = 1.0;
config.success.message = "Success!";

// The amount of seconds the preview should be visible for, should be a float.
config.previewDuration = 1.0;

```

## Android only

```dart
// What the default color conversion will be (grayscale, original).
config.defaultColor = DefaultColor.original;

// Where to put the image results.
config.storagePath = "/sdcard/scanner";

// The filename to use for the output images, supports replacement tokens %dateTime% and %randomUUID%.
config.outputFileName = "KlippaScannerExample-%dateTime%-%randomUUID%";

// To limit the amount of images that can be taken.
config.imageLimit = 10;

// The message to display when the limit has been reached.
config.imageLimitReachedMessage = "You have reached the image limit";

// The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 50).
config.imageMovingSensitivityAndroid = 50;
```

## iOS only
```dart
// The warning message when the camera result is too bright.
config.imageTooBrightMessage = "The image is too bright";

// The warning message when the camera result is too dark.
config.imagetooDarkMessage = "The image is too dark";

// Whether the camera has a view finder overlay (a helper grid so the user knows where the document should be), should be a Boolean.
config.isViewFinderEnabled = true;

// Whether the camera automatically saves the images to the camera roll. Default true.
config.storeImagesToCameraRol = true;

// The threshold sensitive the motion detection is. (lower value is higher sensitivity, default 200).
config.imageMovingSensitivityiOS = 200;
```


## How to change the colors of the SDK?

### Android

Add or edit the file `android/app/src/res/values/colors.xml`, add the following:

```XML
<resources>
    <color name="klippa_scanner_sdk_color_Primary">#fcba03</color>
    <color name="klippa_scanner_sdk_color_PrimaryDark">#805e01</color>
    <color name="klippa_scanner_sdk_color_Accent">#07c6e3</color>
    <color name="klippa_scanner_sdk_color_Overlay">#4a507d</color>
    <color name="klippa_scanner_sdk_color_Warning">#bf1ba9</color>
    <color name="klippa_scanner_sdk_color_IconDisabledColor">#fcba03</color>
    <color name="klippa_scanner_sdk_color_IconEnabledColor">#07c6e3</color>
    <color name="klippa_scanner_sdk_color_ReviewIconColor">#07c6e3</color>
</resources>
```

### iOS

Use the following properties in the config:

```dart
config.accentColor = Color.fromARGB(255, 219, 73, 73);
config.primaryColor = Color.fromARGB(255, 0, 59, 255);
config.overlayColor = Color.fromARGB(255, 255, 0, 191);
config.warningBackgroundColor = Color.fromARGB(255, 252, 252, 252);
config.warningTextColor = Color.fromARGB(255, 0, 0, 0);
config.iconEnabledColor = Color.fromARGB(255, 0, 59, 255);
config.iconDisabledColor = Color.fromARGB(255, 255, 0, 191);
config.reviewIconColor = Color.fromARGB(255, 219, 73, 73);
config.overlayColorAlpha = 0.75; // manually set the alpha of the overlay bounding box.
```

## Important iOS notes
Older iOS versions do not ship the Swift libraries. To make sure the SDK works on older iOS versions, you can configure the build to embed the Swift libraries using the build setting `EMBEDDED_CONTENT_CONTAINS_SWIFT = YES`.

We started using XCFrameworks from version 0.1.0, if you want to use that version or up, you need CocoaPod version 1.9.0 or higher.

## Important Android notes
When using a custom trained model for object detection, add the following to your app's build.gradle file to ensure Gradle doesn’t compress the models when building the app:

```groovy
android {
    aaptOptions {
        noCompress "tflite"
    }
}
```

## About Klippa

[Klippa](https://www.klippa.com/en) is a scale-up from [Groningen, The Netherlands](https://goo.gl/maps/CcCGaPTBz3u8noSd6) and was founded in 2015 by six Dutch IT specialists with the goal to digitize paper processes with modern technologies.

We help clients enhance the effectiveness of their organization by using machine learning and OCR. Since 2015 more than a 1000 happy clients have been served with a variety of the software solutions that Klippa offers. Our passion is to help our clients to digitize paper processes by using smart apps, accounts payable software and data extraction by using OCR.

## License

The MIT License (MIT)
