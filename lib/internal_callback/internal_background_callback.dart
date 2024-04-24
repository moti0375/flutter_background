import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background/utils/constants.dart';

const String _LOG_TAG = "[FlutterBackgroundCallback]";

Future<dynamic> _internalMethodCallHandler(MethodCall call) async {
  String method = call.method;
  print("$_LOG_TAG received $method, with arguments: ${call.arguments}");
  if (method == 'FlutterBackground#BackgroundMessage') {
     _processBackgroundMessage(methodCall: call);
  }
}

void _processBackgroundMessage({required MethodCall methodCall}) async {
  try {
    var appCallbackHandleId = methodCall.arguments[ARG_APP_CALLBACK_HANDLE];
    print('$_LOG_TAG: appCallbackHandleId: $appCallbackHandleId ${appCallbackHandleId.runtimeType}');

    final CallbackHandle appCallbackHandle = CallbackHandle.fromRawHandle(appCallbackHandleId); //Getting the host app callback raw handle from call

    final appCallback = PluginUtilities.getCallbackFromHandle(appCallbackHandle)! as Future<void> Function(Map<String, dynamic>);

    Map<String, dynamic> sdkEventEmitterMessage = Map<String, dynamic>.from(methodCall.arguments[ARG_MESSAGE]);
    await appCallback(sdkEventEmitterMessage); //Calls app headless callback!!
  } catch (e) {
    print('$_LOG_TAG FlutterFire Messaging: An error occurred in your background messaging handler: ${e}');
  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void pluginBackgroundInternalCallback() {
  print("[BackgroundPluginInitializer]: internal callback invoked from native!!");
  WidgetsFlutterBinding.ensureInitialized();
  MethodChannel internalMethodChannel =
  const MethodChannel('com.bartovapps.flutter_background/internal_method_channel');
  internalMethodChannel.setMethodCallHandler(_internalMethodCallHandler);
  internalMethodChannel.invokeMethod("FlutterBackground#OnListen");
}
