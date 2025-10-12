import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:liveness_sdk/liveness_sdk.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _livenessResult = 'No liveness check performed yet';
  bool _isLoading = false;
  final _livenessSdkPlugin = LivenessSdk();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _livenessSdkPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _startLivenessCheck() async {
    setState(() {
      _isLoading = true;
      _livenessResult = 'Starting liveness check...';
    });

    try {
      // Configure the UI (optional)
      final config = LivenessUIConfig(
        hideBranding: false,
        customTitle: 'Verify Your Identity',
        theme: 'light',
        primaryColorHex: '#2196F3',
      );

      // TODO: Replace with your actual session ID from your backend
      // You should get this from your server before calling startLiveness
      final sessionId = '3bb7f90d-fe56-481c-bec4-81c2e79c6caa';
      final region = 'us-east-1'; // Your AWS region

      // Start the liveness check
      final result = await _livenessSdkPlugin.startLiveness(
        sessionId: sessionId,
        region: region,
        config: config,
      );

      debugPrint('liveness result: ${result.status}, message: ${result.message}');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _livenessResult = '✅ Success: ${result.message}';
        } else {
          _livenessResult = '❌ Failed: ${result.message}';
        }
      });

      // Handle success - navigate to next screen, call your API, etc.
      if (result.isSuccess) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _livenessResult = '❌ Error: ${e.toString()}';
      });

      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: const Text('Liveness check completed successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Liveness check failed:\n$error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liveness SDK Example'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.face_retouching_natural,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Running on: $_platformVersion',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _livenessResult,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _startLivenessCheck,
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.face),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Start Liveness Check',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: Make sure to replace the sessionId\nwith a valid one from your backend',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}