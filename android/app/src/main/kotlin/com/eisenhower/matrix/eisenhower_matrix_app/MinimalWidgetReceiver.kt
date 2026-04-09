package com.eisenhower.matrix.todo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

class MinimalWidgetReceiver : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        // Read settings
        val settingsJson = prefs.getString("minimal_widget_settings", null)
        val settings = parseSettings(settingsJson)

        // Read tasks
        val tasksJson = prefs.getString("minimal_widget_tasks", null)
        val tasks = parseTasks(tasksJson)

        // Create RemoteViews
        val views = RemoteViews(context.packageName, R.layout.minimal_widget)

        // Set text color and size for all task TextViews
        val textColor = if (settings.textColor == "white") {
            Color.WHITE
        } else {
            Color.BLACK
        }

        val textSize = when (settings.textSize) {
            "small" -> 12f
            "large" -> 16f
            else -> 14f // medium
        }

        // Array of task TextView IDs
        val taskViewIds = arrayOf(
            R.id.task_1,
            R.id.task_2,
            R.id.task_3,
            R.id.task_4,
            R.id.task_5
        )

        val gravity = when (settings.textAlignment) {
            "center" -> Gravity.CENTER
            "right" -> Gravity.RIGHT or Gravity.CENTER_VERTICAL
            else -> Gravity.LEFT or Gravity.CENTER_VERTICAL
        }

        // Update each task TextView
        for (i in taskViewIds.indices) {
            val viewId = taskViewIds[i]

            if (i < tasks.size && i < settings.taskCount) {
                // Show task
                views.setViewVisibility(viewId, View.VISIBLE)
                views.setTextViewText(viewId, tasks[i])
                views.setTextColor(viewId, textColor)
                views.setFloat(viewId, "setTextSize", textSize)
                views.setInt(viewId, "setGravity", gravity)
                views.setString(viewId, "setFontVariationSettings", "'ROND' 100")
            } else {
                // Hide unused task slots
                views.setViewVisibility(viewId, View.GONE)
            }
        }

        // Set click intent to open app
        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.task_1, pendingIntent)
        views.setOnClickPendingIntent(R.id.task_2, pendingIntent)
        views.setOnClickPendingIntent(R.id.task_3, pendingIntent)
        views.setOnClickPendingIntent(R.id.task_4, pendingIntent)
        views.setOnClickPendingIntent(R.id.task_5, pendingIntent)

        // Update widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun parseSettings(json: String?): WidgetSettings {
        if (json == null) return WidgetSettings()

        try {
            val obj = JSONObject(json)
            return WidgetSettings(
                taskCount = obj.optInt("task_count", 3),
                textColor = obj.optString("text_color", "white"),
                textSize = obj.optString("text_size", "medium"),
                fallbackToNextQuadrants = obj.optBoolean("fallback_to_next_quadrants", false),
                textAlignment = obj.optString("text_alignment", "left")
            )
        } catch (e: Exception) {
            return WidgetSettings()
        }
    }

    private fun parseTasks(json: String?): List<String> {
        if (json == null) return emptyList()

        try {
            val arr = JSONArray(json)
            val tasks = mutableListOf<String>()
            for (i in 0 until arr.length()) {
                tasks.add(arr.getString(i))
            }
            return tasks
        } catch (e: Exception) {
            return emptyList()
        }
    }

    private data class WidgetSettings(
        val taskCount: Int = 3,
        val textColor: String = "white",
        val textSize: String = "medium",
        val fallbackToNextQuadrants: Boolean = false,
        val textAlignment: String = "left"
    )
}
