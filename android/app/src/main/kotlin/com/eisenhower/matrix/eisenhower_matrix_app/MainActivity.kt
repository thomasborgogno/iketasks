package com.eisenhower.matrix.todo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import androidx.glance.appwidget.updateAll
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {

    private val channelName = "com.eisenhower.matrix/widget"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        
        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "forceWidgetUpdate" -> {
                    lifecycleScope.launch {
                        try {
                            EisenhowerGlanceWidget().updateAll(applicationContext)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UPDATE_FAILED", e.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onPostResume() {
        super.onPostResume()
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.getBooleanExtra(EXTRA_OPEN_ADD_TASK, false) == true) {
            methodChannel?.invokeMethod("openAddTask", null)
        }
    }
}