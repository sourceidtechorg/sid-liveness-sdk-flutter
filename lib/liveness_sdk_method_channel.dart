import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'liveness_sdk.dart';
import 'liveness_sdk_platform_interface.dart';

/// An implementation of [LivenessSdkPlatform] that uses method channels.
class MethodChannelLivenessSdk extends LivenessSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('liveness_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }


  @override
  Future<LivenessResult> startLiveness({
    required String sessionId,
    required String region,
    required LivenessUIConfig config,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'startLiveness',
        {
          'sessionId': sessionId,
          'region': region,
          ...config.toMap(),
        },
      );

      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'Received null result from native platform',
        );
      }

      return LivenessResult.fromMap(result);
    } on PlatformException catch (e) {
      throw Exception('Liveness check failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during liveness check: $e');
    }
  }
}
