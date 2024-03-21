import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background/utils/constants.dart';

const String _LOG_TAG = "[FlutterBackgroundCallback]";

Future<dynamic> _internalMethodCallHandler(MethodCall call) async {
  String method = call.method;
  print("$_LOG_TAG received $method, with arguments: ${call.arguments}");
  if (method == 'FlutterBackground#BackgroundMessage') {
    print("[BackgroundPluginInitializer]: FlutterBackground#BackgroundMessage, about to forward event to app background callback..");

    try {
      var appCallbackHandleId = call.arguments[ARG_APP_CALLBACK_HANDLE];
      print('$LogicalKeyboardKey: appCallbackHandleId: $appCallbackHandleId ${appCallbackHandleId.runtimeType}');

      final CallbackHandle appCallbackHandle = CallbackHandle.fromRawHandle(appCallbackHandleId); //Getting the host app callback raw handle from call
      print('$_LOG_TAG: appCallbackHandle: $appCallbackHandle');

      final appCallback = PluginUtilities.getCallbackFromHandle(appCallbackHandle)! as Future<void> Function(Map<String, dynamic>);

      Map<String, dynamic> sdkEventEmitterMessage = Map<String, dynamic>.from(call.arguments[ARG_MESSAGE]);
      print('$_LOG_TAG: backgroundMessage: $sdkEventEmitterMessage');
      await appCallback(sdkEventEmitterMessage); //Calls app headless callback!!
    } catch (e) {
      print('$_LOG_TAG FlutterFire Messaging: An error occurred in your background messaging handler: ${e}');
      print(e);
    }

  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void pluginBackgroundInternalCallback() {
  print("[BackgroundPluginInitializer]: internal callback invoked from native!!");
  WidgetsFlutterBinding.ensureInitialized();
  MethodChannel internalMethodChannel =
  const MethodChannel('com.bartovapps.flutter_background/internal_method_channel');
  internalMethodChannel.setMethodCallHandler(_internalMethodCallHandler);
  internalMethodChannel.invokeMethod("FlutterBackground#Initialize");
}
