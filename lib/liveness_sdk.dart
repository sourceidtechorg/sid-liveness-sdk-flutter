
import 'liveness_sdk_platform_interface.dart';


/// Configuration for the Liveness UI
class LivenessUIConfig {
  final bool hideBranding;
  final String? customTitle;
  final String theme; // "light" or "dark"
  final String? primaryColorHex;

  LivenessUIConfig({
    this.hideBranding = false,
    this.customTitle,
    this.theme = 'light',
    this.primaryColorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'hideBranding': hideBranding,
      'customTitle': customTitle,
      'theme': theme,
      'primaryColorHex': primaryColorHex,
    };
  }
}

/// Result from the liveness check
class LivenessResult {
  final String status;
  final String message;

  LivenessResult({
    required this.status,
    required this.message,
  });

  bool get isSuccess => status == 'success';

  factory LivenessResult.fromMap(Map<dynamic, dynamic> map) {
    return LivenessResult(
      status: map['status'] as String,
      message: map['message'] as String,
    );
  }
}

class LivenessSdk {
  Future<String?> getPlatformVersion() {
    return LivenessSdkPlatform.instance.getPlatformVersion();
  }

  /// Starts the liveness check flow
  ///
  /// [sessionId] - The session ID from your backend
  /// [region] - The AWS region (e.g., "us-east-1")
  /// [config] - Optional UI configuration
  ///
  /// Returns a [LivenessResult] with the outcome
  /// Throws an exception if the liveness check fails
  Future<LivenessResult> startLiveness({
    required String sessionId,
    required String region,
    LivenessUIConfig? config,
  }) async {
    return LivenessSdkPlatform.instance.startLiveness(
      sessionId: sessionId,
      region: region,
      config: config ?? LivenessUIConfig(),
    );
  }
}
