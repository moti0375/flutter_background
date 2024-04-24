package com.bartovapps.flutter_background.utils

import android.content.Context
import java.lang.ref.WeakReference

internal object ContextHolder {
    private lateinit var contextReference: WeakReference<Context>
    val context: Context
        get() = contextReference.get() ?: throw IllegalStateException("Context hasn't been provided properly")
    fun initialize(context: Context){
        this.contextReference = WeakReference(context)
    }
}