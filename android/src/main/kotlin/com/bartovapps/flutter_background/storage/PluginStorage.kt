package com.bartovapps.flutter_background.storage

import android.content.Context
import android.content.SharedPreferences
import com.bartovapps.flutter_background.utils.ContextHolder

object PluginStorage {

    private lateinit var sharedPreferences : SharedPreferences
    fun initialize() {
        sharedPreferences = ContextHolder.context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun saveAppRawHandle(rawHandle: Long) : Boolean {
        return saveOrReplaceLong(APP_CALLBACK_HANDLE_KEY, rawHandle)
    }

    fun getAppRawHandle(): Long {
        return sharedPreferences.getLong(APP_CALLBACK_HANDLE_KEY, -1L);
    }

    fun saveInternalRawHandle(rawHandle: Long) : Boolean {
        return saveOrReplaceLong(INTERNAL_CALLBACK_HANDLE_KEY, rawHandle)
    }

    fun getInternalRawHandle(): Long {
        return sharedPreferences.getLong(INTERNAL_CALLBACK_HANDLE_KEY, -1L)
    }


    fun backgroundAllowed() : Boolean {
        return isExists(INTERNAL_CALLBACK_HANDLE_KEY) && isExists(APP_CALLBACK_HANDLE_KEY)
    }

    private fun isExists(key: String) : Boolean {
        return sharedPreferences.contains(key);
    }

    private fun saveOrReplaceLong(key: String, value: Long) : Boolean {
        if(!isExists(key) || sharedPreferences.getLong(key, -1L) != value){
            sharedPreferences.edit().putLong(key, value).apply()
            return true
        }
        return false
    }

    private  const val PREFS_NAME = "BACKGROUND_PREFERENCES"
    private  const val APP_CALLBACK_HANDLE_KEY = "app_callback_raw_handle"
    private  const val INTERNAL_CALLBACK_HANDLE_KEY = "ineternal_callback_raw_handle"

}