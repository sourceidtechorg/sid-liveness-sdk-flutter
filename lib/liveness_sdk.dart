
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

/// Connection details for the SourceID gateway, used to verify a liveness
/// session's status before the capture flow launches. When provided, the
/// native SDK only opens the camera if the session status is `CREATED`.
class LivenessApiConfig {
  /// Gateway API base, e.g. `https://api-rd.tailfaed50.ts.net/v1/api`.
  final String baseUrl;

  /// Value for the `x-api-key` header.
  final String apiKey;

  /// Value for the `Authorization: Bearer` header. Tokens expire — supply a
  /// fresh one per launch.
  final String bearerToken;

  LivenessApiConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.bearerToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'bearerToken': bearerToken,
    };
  }
}

/// Thrown when the liveness check fails or is cancelled.
///
/// [message] is friendly, actionable text safe to show end users;
/// [debugMessage] carries the full technical detail for logging (the native
/// SDKs also log every failure themselves — Android: Logcat tag
/// `LivenessSDK`; iOS: os_log subsystem `tech.sourceid.LivenessCheck`).
///
/// [code] mirrors the native error code:
/// - `CANCELLED` — the user backed out of the flow
/// - `CAMERA_PERMISSION_DENIED` — the camera permission was declined
/// - `INVALID_ARGUMENTS` — sessionId missing/blank
/// - `SESSION_NOT_USABLE` — pre-flight check: session already used or expired
/// - `STATUS_CHECK_FAILED` — pre-flight check couldn't reach the gateway
/// - `CONFIG_FAILED` — AWS Amplify could not be configured
/// - `DETECTOR_FAILED` — the AWS detector failed (network, expired session, ...)
/// - `NO_ACTIVITY` / `NO_VIEW_CONTROLLER` — no UI to present from
/// - `IN_PROGRESS` — another liveness flow is already running
class LivenessException implements Exception {
  final String code;
  final String? message;
  final String? debugMessage;

  LivenessException({required this.code, this.message, this.debugMessage});

  /// True when the user cancelled the flow rather than failing it.
  bool get isCancelled => code == 'CANCELLED';

  @override
  String toString() =>
      'LivenessException($code): ${debugMessage ?? message ?? 'no message'}';
}

/// Result from the liveness check.
///
/// [sessionStatus], [confidence], and [referenceImageUrl] carry the scored
/// gateway result and are populated when [LivenessApiConfig] was provided to
/// `startLiveness` — the SDK fetches them from `liveness-result` right after
/// the capture completes. They are null when no [LivenessApiConfig] was
/// given or the post-completion fetch failed (the capture still succeeded;
/// fetch the result from your backend in that case).
class LivenessResult {
  final String status;
  final String message;

  /// Gateway session status, e.g. `SUCCEEDED`.
  final String? sessionStatus;

  /// Rekognition confidence score (0–100) that the user is a live person.
  final double? confidence;

  /// Short-lived signed URL of the captured reference image.
  final String? referenceImageUrl;

  LivenessResult({
    required this.status,
    required this.message,
    this.sessionStatus,
    this.confidence,
    this.referenceImageUrl,
  });

  bool get isSuccess => status == 'success';

  factory LivenessResult.fromMap(Map<dynamic, dynamic> map) {
    return LivenessResult(
      status: map['status'] as String,
      message: map['message'] as String,
      sessionStatus: map['sessionStatus'] as String?,
      confidence: (map['confidence'] as num?)?.toDouble(),
      referenceImageUrl: map['referenceImageUrl'] as String?,
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
  /// [region] - The AWS region (defaults to "us-east-1")
  /// [config] - Optional UI configuration
  /// [apiConfig] - Optional gateway credentials; when provided the native SDK
  /// verifies the session status first and only opens the camera if it is
  /// `CREATED`
  ///
  /// Returns a [LivenessResult] with the outcome.
  /// Throws a [LivenessException] if the liveness check fails or is cancelled.
  Future<LivenessResult> startLiveness({
    required String sessionId,
    String region = 'us-east-1',
    LivenessUIConfig? config,
    LivenessApiConfig? apiConfig,
  }) async {
    return LivenessSdkPlatform.instance.startLiveness(
      sessionId: sessionId,
      region: region,
      config: config ?? LivenessUIConfig(),
      apiConfig: apiConfig,
    );
  }
}
