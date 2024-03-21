import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background/internal_callback/internal_background_callback.dart';
import 'package:flutter_background/utils/constants.dart';
import 'flutter_background_platform_interface.dart';
const String _LOG_TAG = "[FlutterBackgroundPlugin]";

/// An implementation of [FlutterBackgroundPlatform] that uses method channels.
class MethodChannelFlutterBackground extends FlutterBackgroundPlatform {

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.bartovapps.flutter_background/method_channel');
  bool _bgHandlerInitialized = false;

  @override
  Future registerBackgroundCallback(Function callback) async {
    if (!_bgHandlerInitialized) {
      int? appCallbackRawHandle = _generateRawHandle(callback);
      int? internalRawHandle = _generateRawHandle(pluginBackgroundInternalCallback);
      print(
          "registerBackgroundCallback: appCallbackRawHandle: $appCallbackRawHandle, internalRawHandle: $internalRawHandle");
      if (appCallbackRawHandle != null && internalRawHandle != null) {
        var result = await methodChannel.invokeMethod("registerBackgroundCallback", {
          ARG_APP_CALLBACK_HANDLE_: appCallbackRawHandle,
          ARG_INTERNAL_CALLBACK_HANDLE: internalRawHandle,
          ARG_INTERNAL_CALLBACK_NAME: "pluginBackgroundInternalCallback", //For ios
          ARG_INTERNAL_CALLBACK_URL_: "package:flutter_background/internal_callback/internal_background_callback.dart"
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