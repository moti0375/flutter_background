package com.bartovapps.flutter_background_example

import android.util.Log
import com.bartovapps.flutter_background.FlutterBackgroundPlugin
import io.flutter.app.FlutterApplication

class MyApplication: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        Log.i("MyApplication", "onCreate")
        FlutterBackgroundPlugin.emitBackgroundEvent(mapOf("action" to "AppLaunch"))
    }
}