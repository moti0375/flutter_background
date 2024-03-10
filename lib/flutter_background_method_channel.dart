import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_background_platform_interface.dart';
const String _LOG_TAG = "[FlutterBackgroundPlugin]";
const _ARG_APP_CALLBACK_HANDLE = "appCallbackRawHandle";
const _ARG_MESSAGE = "message";

/// An implementation of [FlutterBackgroundPlatform] that uses method channels.
class MethodChannelFlutterBackground extends FlutterBackgroundPlatform {
  static const String _ARG_INTERNAL_CALLBACK_HANDLE = "internalCallbackRawHandle";
  static const String _ARG_APP_CALLBACK_HANDLE_ = "appCallbackRawHandle";
  static const String _ARG_INTERNAL_CALLBACK_NAME = "internalCallbackName";
  static const String _ARG_INTERNAL_CALLBACK_URL_ = "internalCallbackNameUrl";


  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.bartovapps.flutter_background/method_channel');
  bool _bgHandlerInitialized = false;

  @override
  Future registerBackgroundCallback(Function callback) async {
    if (!_bgHandlerInitialized) {
      int? appCallbackRawHandle = _generateRawHandle(callback);
      int? internalRawHandle = _generateRawHandle(_pluginBackgroundInternalCallback);
      print(
          "registerBackgroundCallback: appCallbackRawHandle: $appCallbackRawHandle, internalRawHandle: $internalRawHandle");
      if (appCallbackRawHandle != null && internalRawHandle != null) {
        var result = await methodChannel.invokeMethod("registerBackgroundCallback", {
          _ARG_APP_CALLBACK_HANDLE_: appCallbackRawHandle,
          _ARG_INTERNAL_CALLBACK_HANDLE: internalRawHandle,
          _ARG_INTERNAL_CALLBACK_NAME: "_pluginBackgroundInternalCallback", //For ios
          _ARG_INTERNAL_CALLBACK_URL_: "package:plugin_platform_interface"
        });
        _bgHandlerInitialized = true;
        return result;
      } else {
        return Future(() => ArgumentError("Unable to register app  background callback"));
      }
    }
  }

  int? _generateRawHandle(Function callback) {
    final cb = PluginUtilities.getCallbackHandle(callback);
    assert(cb != null,
        "The dispatcher needs to be a static function or a top level function to be accessible as a Flutter entry point.");
    return cb?.toRawHandle();
  }
}

Future<dynamic> _internalMethodCallHandler(MethodCall call) async {
  String method = call.method;
  print("$_LOG_TAG received $method, with arguments: ${call.arguments}");
  if (method == 'FlutterBackground#BackgroundMessage') {
    print("[BackgroundPluginInitializer]: FlutterBackground#BackgroundMessage, about to forward event to app background callback..");

    try {
      var appCallbackHandleId = call.arguments[_ARG_APP_CALLBACK_HANDLE];
      print('$LogicalKeyboardKey: appCallbackHandleId: $appCallbackHandleId ${appCallbackHandleId.runtimeType}');

      final CallbackHandle appCallbackHandle = CallbackHandle.fromRawHandle(appCallbackHandleId); //Getting the host app callback raw handle from call
      print('$_LOG_TAG: appCallbackHandle: $appCallbackHandle');

      final appCallback = PluginUtilities.getCallbackFromHandle(appCallbackHandle)! as Future<void> Function(Map<String, dynamic>);

      Map<String, dynamic> sdkEventEmitterMessage = Map<String, dynamic>.from(call.arguments[_ARG_MESSAGE]);
      print('$_LOG_TAG: backgroundMessage: $sdkEventEmitterMessage');
      await appCallback(sdkEventEmitterMessage); //Calls app headless callback!!
    } catch (e) {
      print('$_LOG_TAG FlutterFire Messaging: An error occurred in your background messaging handler: ${e}');
      print(e);
    }

  }
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void _pluginBackgroundInternalCallback() {
  print("[BackgroundPluginInitializer]: internal callback invoked from native!!");
  WidgetsFlutterBinding.ensureInitialized();
  MethodChannel internalMethodChannel =
      const MethodChannel('com.bartovapps.flutter_background/internal_method_channel');
  internalMethodChannel.setMethodCallHandler(_internalMethodCallHandler);
  internalMethodChannel.invokeMethod("FlutterBackground#Initialize");
}
