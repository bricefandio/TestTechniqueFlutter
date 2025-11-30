package com.rn_app

import android.content.Intent
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class FlutterUserSdkModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = "FlutterUserSdk"

    @ReactMethod
    fun openUserProfile(userId: Int) {
        val activity = currentActivity ?: return
        val intent = Intent(activity, FlutterHostActivity::class.java)
        intent.putExtra("userId", userId)
        activity.startActivity(intent)
    }
}
