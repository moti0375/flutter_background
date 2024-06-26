package com.bartovapps.flutter_background.background_emitter

import android.content.Context
import android.content.res.AssetManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.bartovapps.flutter_background.FlutterBackgroundPlugin.Companion.ARG_APP_CALLBACK_HANDLE
import com.bartovapps.flutter_background.storage.PluginStorage
import com.bartovapps.flutter_background.utils.ContextHolder
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.view.FlutterCallbackInformation
import java.lang.Error
import java.lang.ref.WeakReference
import java.util.Collections
import java.util.LinkedList

internal object BackgroundEmitter : MethodCallHandler {

    private const val LOG_TAG = "BackgroundEmitter"
    private const val INTERNAL_METHOD_CHANNEL = "com.bartovapps.flutter_background/internal_method_channel"
    private const val MESSAGE = "message"
    private val handler = Handler(Looper.getMainLooper())
    private var internalMethodChannel: MethodChannel? = null
    private var ready: Boolean = false
    private lateinit var flutterLoader : FlutterLoader
    private lateinit var flutterEngine: FlutterEngine
    private val pendingEventsQueue: MutableList<Map<String, Any?>> = Collections.synchronizedList(LinkedList())

    internal fun initialize(force: Boolean = false) {
        if(force){
            Log.i(LOG_TAG, "forced to initialize background emitter")
            initializeBackgroundEmitter()
        }
    }

    fun emitEventsToDart(event: Map<String, Any?>) {
        Log.i(LOG_TAG, "About to send: $event to Flutter in background")
        if (ready) {
            runAsync(operation = {
                val appRawHandle = PluginStorage.getAppRawHandle()
                val params = mapOf(ARG_APP_CALLBACK_HANDLE to appRawHandle, MESSAGE to event)
                internalMethodChannel?.invokeMethod("FlutterBackground#BackgroundMessage", params)
            }, error = {
                Log.e(LOG_TAG, "Something went wrong: ${it.message}")
            })
        } else {
            Log.i(LOG_TAG, "BackgroundEmitter not ready yet, enqueue event until it will be ready")
            enqueuePendingEvent(event)
            initializeBackgroundEmitter()
        }
    }

    private fun enqueuePendingEvent(event: Map<String, Any?>) {
        synchronized(pendingEventsQueue) {
            pendingEventsQueue.add(event)
        }
    }

    private fun storeContext(context: Context){
        if (!PluginStorage.backgroundAllowed()) {
            Log.i(LOG_TAG, "Background work not allowed, To enable background use the registerBackgroundCallback in your app main.dart")
            return
        }
    }

    private fun initializeBackgroundEmitter() {
        Log.i(LOG_TAG, "initializeBackgroundEmitter: ")
        this.flutterLoader = FlutterLoader()
        ContextHolder.context.applicationContext?.let { applicationContext ->
            flutterLoader.let {
                it.startInitialization(applicationContext)
                it.ensureInitializationCompleteAsync(applicationContext, null, handler) {
                    Log.i(LOG_TAG, "ensureInitializationComplete, completed")
                    invokePluginInternalCallbackInBackground(applicationContext) //Call single shot when created..
                }
            }
        }
    }

    private fun invokePluginInternalCallbackInBackground(context: Context) {
        val internalCallbackRawHandle = PluginStorage.getInternalRawHandle()

        if (internalCallbackRawHandle != -1L) {
            Log.i(LOG_TAG, "executeDartCallback: backgroundCallback available")
            flutterEngine = FlutterEngine(context)
            val flutterCallback = FlutterCallbackInformation.lookupCallbackInformation(internalCallbackRawHandle)
            val dartExecutor = flutterEngine.dartExecutor
            initializeInternalMethodChannel(dartExecutor)
            val assets: AssetManager = context.assets
            val dartCallback = DartCallback(assets, flutterLoader.findAppBundlePath(), flutterCallback)

            runAsync(operation = {
                Log.i(LOG_TAG, "invokePluginInternalCallbackInBackground: internalCallbackRawHandle $internalCallbackRawHandle")
                dartExecutor.executeDartCallback(dartCallback)
            }, error = {
                Log.e(LOG_TAG, "Something went wrong: ${it.message}")
            })
        } else {
            Log.e(LOG_TAG, "Invalid internal callback raw handler..")
        }
    }

    private fun initializeInternalMethodChannel(dartExecutor: DartExecutor) {
        internalMethodChannel = MethodChannel(dartExecutor, INTERNAL_METHOD_CHANNEL).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(LOG_TAG, "onMethodCall: ${call.method}")
        if (call.method == "FlutterBackground#OnListen") {
            Log.i(LOG_TAG, "Background isolate initialized")
            ready = true
            flushPendingEventsQueue()
        }
    }

    private fun flushPendingEventsQueue() {
        synchronized(pendingEventsQueue) {
            if (pendingEventsQueue.isNotEmpty()) {
                Log.i(LOG_TAG, "flushPendingEventsQueue: pendingEventsQueue not empty flush all events to Dart")
                pendingEventsQueue.apply {
                    forEach {
                        emitEventsToDart(it)
                    }
                    clear()
                }
            }
        }
    }

    private fun <T> runAsync(operation: () -> T?, error: ((Throwable) -> Unit)? = null, success: ((T?) -> Unit)? = null) {
        handler.post {
            runCatching {
                val result = operation()
                result
            }.onSuccess {
                success?.invoke(it)
            }.onFailure {
                error?.invoke(it)
            }
        }
    }
}