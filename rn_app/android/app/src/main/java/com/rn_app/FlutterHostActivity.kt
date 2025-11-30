package com.rn_app

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class FlutterHostActivity : FlutterActivity() {

    private val CHANNEL = "flutter_user_sdk/user"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val userId = intent.getIntExtra("userId", -1)
        val engine = FlutterEngineCache.getInstance().get("flutter_user_engine")

        if (engine != null && userId != -1) {
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("showUserProfile", mapOf("userId" to userId))
        }
    }

    override fun provideFlutterEngine(context: Context) =
        FlutterEngineCache.getInstance().get("flutter_user_engine")
}
