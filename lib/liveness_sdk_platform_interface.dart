import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'liveness_sdk.dart';
import 'liveness_sdk_method_channel.dart';

abstract class LivenessSdkPlatform extends PlatformInterface {
  /// Constructs a LivenessSdkPlatform.
  LivenessSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static LivenessSdkPlatform _instance = MethodChannelLivenessSdk();

  /// The default instance of [LivenessSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelLivenessSdk].
  static LivenessSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LivenessSdkPlatform] when
  /// they register themselves.
  static set instance(LivenessSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<LivenessResult> startLiveness({
    required String sessionId,
    required String region,
    required LivenessUIConfig config,
    LivenessApiConfig? apiConfig,
  }) {
    throw UnimplementedError('startLiveness() has not been implemented.');
  }
}
