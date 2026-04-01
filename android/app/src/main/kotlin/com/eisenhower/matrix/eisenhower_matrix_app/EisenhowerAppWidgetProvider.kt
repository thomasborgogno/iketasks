package com.eisenhower.matrix.todo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONObject

class EisenhowerAppWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = buildRemoteViews(context)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    companion object {
        private const val PREFS = "HomeWidgetPreferences"

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, EisenhowerAppWidgetProvider::class.java),
            )

            ids.forEach { id ->
                manager.updateAppWidget(id, buildRemoteViews(context))
            }
        }

        private fun buildRemoteViews(context: Context): RemoteViews {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val payload = prefs.getString("matrix_payload", null)

            val views = RemoteViews(context.packageName, R.layout.eisenhower_widget)
            if (payload.isNullOrBlank()) {
                views.setTextViewText(R.id.q1_tasks, "Nessuna task")
                views.setTextViewText(R.id.q2_tasks, "Nessuna task")
                views.setTextViewText(R.id.q3_tasks, "Nessuna task")
                views.setTextViewText(R.id.q4_tasks, "Nessuna task")
            } else {
                val json = JSONObject(payload)
                views.setTextViewText(R.id.q1_tasks, formatList(json.optJSONArray("q1")))
                views.setTextViewText(R.id.q2_tasks, formatList(json.optJSONArray("q2")))
                views.setTextViewText(R.id.q3_tasks, formatList(json.optJSONArray("q3")))
                views.setTextViewText(R.id.q4_tasks, formatList(json.optJSONArray("q4")))
            }

            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )

            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            return views
        }

        private fun formatList(array: org.json.JSONArray?): String {
            if (array == null || array.length() == 0) {
                return "Nessuna task"
            }

            val lines = mutableListOf<String>()
            for (i in 0 until array.length()) {
                val item = array.getJSONObject(i)
                val done = if (item.optBoolean("completed")) "[x]" else "[ ]"
                val title = item.optString("title", "Task")
                lines.add("$done $title")
            }
            return lines.joinToString("\n")
        }
    }
}
