import 'package:flutter_test/flutter_test.dart';
import 'package:liveness_sdk/liveness_sdk.dart';
import 'package:liveness_sdk/liveness_sdk_platform_interface.dart';
import 'package:liveness_sdk/liveness_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLivenessSdkPlatform
    with MockPlatformInterfaceMixin
    implements LivenessSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<LivenessResult> startLiveness({required String sessionId, required String region, required LivenessUIConfig config, LivenessEnvironment? environment, String? apiKey}) {
    // TODO: implement startLiveness
    throw UnimplementedError();
  }
}

void main() {
  final LivenessSdkPlatform initialPlatform = LivenessSdkPlatform.instance;

  test('$MethodChannelLivenessSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLivenessSdk>());
  });

  test('getPlatformVersion', () async {
    LivenessSdk livenessSdkPlugin = LivenessSdk();
    MockLivenessSdkPlatform fakePlatform = MockLivenessSdkPlatform();
    LivenessSdkPlatform.instance = fakePlatform;

    expect(await livenessSdkPlugin.getPlatformVersion(), '42');
  });
}
