package com.bartovapps.flutter_background.initializer

import android.content.Context
import android.util.Log
import androidx.startup.Initializer
import com.bartovapps.flutter_background.background_emitter.BackgroundEmitter
import com.bartovapps.flutter_background.storage.PluginStorage
import com.bartovapps.flutter_background.utils.ContextHolder

internal class BackgroundPluginInitializer : Initializer<Unit> {

    override fun create(context: Context) {
        Log.i("BackgroundInitializer", "create: ")
        ContextHolder.initialize(context)
        PluginStorage.initialize()
        BackgroundEmitter.initialize()
    }

    override fun dependencies(): MutableList<Class<out Initializer<*>>> {
        return mutableListOf()
    }
}