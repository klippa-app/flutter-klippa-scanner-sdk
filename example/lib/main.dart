import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:klippa_scanner_sdk/klippa_scanner_sdk.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scannerResult = 'Unknown';

  String license = "{your-license}";

  @override
  void initState() {
    super.initState();
  }

  void _startSession() async {
    String sessionResultText = 'Unknown';
    var config = CameraConfig();
    // setup your scanner
    config.storeImagesToCameraRol = true;
    try {
      var result = await KlippaScannerSdk.startSession(config, license);
      sessionResultText = 'Finished';
      print(result);
    } on PlatformException catch (e) {
      sessionResultText = 'Failed to start session ' + e.toString();
    }

    setState(() {
      _scannerResult = sessionResultText;
    });

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Scanner result: $_scannerResult\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _startSession,
          tooltip: 'Start session',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
