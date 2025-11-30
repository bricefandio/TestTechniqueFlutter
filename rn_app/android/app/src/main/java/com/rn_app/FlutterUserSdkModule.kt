package com.rn_app

import android.content.Intent
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class FlutterUserSdkModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = "FlutterUserSdk"

    @ReactMethod
    fun openUserProfile(userId: Int, promise: Promise) {
        val activity = currentActivity
        if (activity == null) {
            promise.reject("NO_ACTIVITY", "Aucune activité React Native disponible.")
            return
        }
        val intent = Intent(activity, FlutterHostActivity::class.java)
        intent.putExtra("userId", userId)
        activity.startActivity(intent)
        promise.resolve(null)
    }
}
