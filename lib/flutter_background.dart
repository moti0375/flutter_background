
import 'flutter_background_platform_interface.dart';

class FlutterBackground {
  Future<void> registerBackgroundCallback(Function callback) {
    return FlutterBackgroundPlatform.instance.registerBackgroundCallback(callback);
  }
}
