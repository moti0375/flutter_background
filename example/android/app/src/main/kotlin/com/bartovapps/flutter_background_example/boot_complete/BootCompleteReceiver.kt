package com.bartovapps.flutter_background_example.boot_complete

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.bartovapps.flutter_background.FlutterBackgroundPlugin

class BootCompleteReceiver : BroadcastReceiver(){
    override fun onReceive(c: Context, intent: Intent) {
        val action = intent.action
        if(action == Intent.ACTION_BOOT_COMPLETED){
            Log.i("BootCompleteReceiver", "onReceive: ")
            FlutterBackgroundPlugin.emitBackgroundEvent(mapOf("action" to "BootComplete"))
        }
    }
}