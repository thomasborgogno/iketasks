package com.iketasks.eisenhower.todo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle

class MainActivity : FlutterActivity() {

    private val channelName = "com.eisenhower.matrix/widget"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
    }

    override fun onPostResume() {
        super.onPostResume()
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent?.getBooleanExtra(EXTRA_OPEN_ADD_TASK, false) == true) {
            methodChannel?.invokeMethod("openAddTask", null)
        }
        if (intent?.getBooleanExtra(EXTRA_OPEN_WIDGET_SETTINGS, false) == true) {
            methodChannel?.invokeMethod("openWidgetSettings", null)
        }
    }
}