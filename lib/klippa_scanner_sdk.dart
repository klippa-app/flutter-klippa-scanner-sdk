
import 'dart:async';

import 'package:flutter/services.dart';

class CameraConfig {
  /// Global options.


}

class KlippaScannerSdk {
  static const MethodChannel _channel =
  const MethodChannel('klippa_scanner_sdk');

  static Future<Map> startSession(final CameraConfig config, String license) async {
    Map<String, dynamic> parameters = {};
    parameters['License'] = license;

    final Map startSessionResult = await _channel.invokeMethod('startSession', parameters);
    return startSessionResult;
  }
}
