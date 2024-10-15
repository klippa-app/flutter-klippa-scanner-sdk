#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint klippa_scanner_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'klippa_scanner_sdk'
  s.version          = '0.2.0'
  s.summary          = 'Allows you to do document scanning with the Klippa Scanner SDK from Flutter apps.'
  s.description      = <<-DESC
Allows you to do document scanning with the Klippa Scanner SDK from Flutter apps.
                       DESC
  s.homepage         = 'https://github.com/klippa-app/flutter-klippa-scanner-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Klippa App BV' => 'robin@klippa.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Klippa-Scanner'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

