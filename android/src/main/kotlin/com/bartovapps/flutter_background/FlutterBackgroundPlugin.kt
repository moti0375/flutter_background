package com.bartovapps.flutter_background

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.bartovapps.flutter_background.background_emitter.BackgroundEmitter
import com.bartovapps.flutter_background.storage.PluginStorage

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.view.FlutterCallbackInformation

/** FlutterBackgroundPlugin */
class FlutterBackgroundPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.bartovapps.flutter_background/method_channel")
    channel.setMethodCallHandler(this)
  }


  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method){
      "registerBackgroundCallback" -> registerBackgroundCallback(call, result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun registerBackgroundCallback(call: MethodCall, result: Result) {
    Log.i("FlutterBackgroundPlugin", "registerBackgroundCallback: arguments: ${call.arguments}")
    val internalCallbackHandle = call.argument<Number>(ARG_INTERNAL_CALLBACK_HANDLE)?.toLong()
    val appCallbackRawHandle = call.argument<Number>(ARG_APP_CALLBACK_HANDLE)?.toLong()

    val internalCallbackSaved = internalCallbackHandle?.let {
      PluginStorage.saveInternalRawHandle(it)
    } ?: false
    Log.i("FlutterBackgroundPlugin", "registerBackgroundCallback: internalCallbackSaved: $internalCallbackSaved")

    val appCallbackSaved =  appCallbackRawHandle?.let{
      PluginStorage.saveAppRawHandle(it)
    } ?: false
    Log.i("FlutterBackgroundPlugin", "registerBackgroundCallback: appCallbackSaved: $appCallbackSaved")

    if(appCallbackSaved || internalCallbackSaved){
      Log.i("FlutterBackgroundPlugin", "RawHandle saved, reinitializing the background emitter")
      BackgroundEmitter.initialize(true) //If any rawHandle saved (it means it changed or saved first time, reinitialize the emitter)
    }
    result.success("")
  }

  companion object{
     private const  val ARG_INTERNAL_CALLBACK_HANDLE = "internalCallbackRawHandle";
     internal const  val ARG_APP_CALLBACK_HANDLE = "appCallbackRawHandle";

    @JvmStatic
    fun emitBackgroundEvent(params: Map<String, Any?>){
      BackgroundEmitter.emitEventsToDart(params)
    }
  }
}
