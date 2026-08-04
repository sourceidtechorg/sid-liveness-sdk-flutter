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
    LivenessApiConfig? apiConfig,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'startLiveness',
        {
          'sessionId': sessionId,
          'region': region,
          ...config.toMap(),
          if (apiConfig != null) 'apiConfig': apiConfig.toMap(),
        },
      );

      if (result == null) {
        throw LivenessException(
          code: 'NULL_RESULT',
          message: 'Received null result from native platform',
        );
      }

      return LivenessResult.fromMap(result);
    } on PlatformException catch (e) {
      // Native code/userMessage/debugMessage arrive as code/message/details.
      throw LivenessException(
        code: e.code,
        message: e.message,
        debugMessage: e.details is String ? e.details as String : null,
      );
    } on LivenessException {
      rethrow;
    } catch (e) {
      throw LivenessException(code: 'UNEXPECTED', message: e.toString());
    }
  }
}
