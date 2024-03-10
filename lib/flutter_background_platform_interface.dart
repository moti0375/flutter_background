import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_background_method_channel.dart';

abstract class FlutterBackgroundPlatform extends PlatformInterface {
  /// Constructs a FlutterBackgroundPlatform.
  FlutterBackgroundPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBackgroundPlatform _instance = MethodChannelFlutterBackground();

  /// The default instance of [FlutterBackgroundPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBackground].
  static FlutterBackgroundPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBackgroundPlatform] when
  /// they register themselves.
  static set instance(FlutterBackgroundPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  ///Registering callback raw handle for calling dart callback in background
  Future<dynamic> registerBackgroundCallback(Function callback);
}
