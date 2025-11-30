package com.rn_app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class FlutterHostActivity : FlutterActivity() {

    private val CHANNEL = "flutter_user_sdk/user"
    private val engine: FlutterEngine?
        get() = FlutterEngineCache.getInstance().get("flutter_user_engine")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sendUserId(intent.getIntExtra("userId", -1))
    }

    override fun provideFlutterEngine(context: Context) =
        FlutterEngineCache.getInstance().get("flutter_user_engine")

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        sendUserId(intent.getIntExtra("userId", -1))
    }

    private fun sendUserId(userId: Int) {
        val cachedEngine = engine ?: return
        if (userId <= 0) return
        MethodChannel(cachedEngine.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("showUserProfile", mapOf("userId" to userId))
    }
}
