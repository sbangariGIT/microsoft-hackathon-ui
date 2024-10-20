import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import for Timer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenshotHome(),
    );
  }
}

class ScreenshotHome extends StatefulWidget {
  @override
  _ScreenshotHomeState createState() => _ScreenshotHomeState();
}

class _ScreenshotHomeState extends State<ScreenshotHome> {
  static const platform = MethodChannel('screenshot_channel');
  Timer? _timer; // Declare a Timer variable
   @override
  void initState() {
    super.initState();
    // Start the periodic timer to take screenshots every 1 minutes
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      takeScreenshot();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> takeScreenshot() async {
    try {
      final result = await platform.invokeMethod('takeScreenshot');
      print('Screenshot saved at: $result');
    } on PlatformException catch (e) {
      print("Failed to take screenshot: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screenshot App')),
      body: Center(
        child: ElevatedButton(
          onPressed: takeScreenshot,
          child: Text('Take Screenshot'),
        ),
      ),
    );
  }
}
