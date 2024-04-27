
import 'flutter_background_platform_interface.dart';
class FlutterBackground {
  FlutterBackground._();
  static FlutterBackground? _instance;
  static FlutterBackground get instance => _instance ??= FlutterBackground._();
  Future<void> registerBackgroundCallback(Function callback) {
    return FlutterBackgroundPlatform.instance.registerBackgroundCallback(callback);
  }
}
