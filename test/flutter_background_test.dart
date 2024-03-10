import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background/flutter_background_platform_interface.dart';
import 'package:flutter_background/flutter_background_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBackgroundPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBackgroundPlatform {
  @override
  Future registerBackgroundCallback(Function callback) {
    throw UnimplementedError();
  }


}

void main() {
  final FlutterBackgroundPlatform initialPlatform = FlutterBackgroundPlatform.instance;

  test('$MethodChannelFlutterBackground is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBackground>());
  });

  test('getPlatformVersion', () async {
    FlutterBackground flutterBackgroundPlugin = FlutterBackground();
    MockFlutterBackgroundPlatform fakePlatform = MockFlutterBackgroundPlatform();
    FlutterBackgroundPlatform.instance = fakePlatform;

  });
}
