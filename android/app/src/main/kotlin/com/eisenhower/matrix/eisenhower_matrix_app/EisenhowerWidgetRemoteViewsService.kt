package com.eisenhower.matrix.todo

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject

class EisenhowerWidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        EisenhowerWidgetFactory(
            applicationContext,
            intent.getStringExtra("quadrant_key") ?: "q1",
        )
}

private class EisenhowerWidgetFactory(
    private val context: Context,
    private val quadrantKey: String,
) : RemoteViewsService.RemoteViewsFactory {

    private data class TaskEntry(val id: String, val title: String)

    private var tasks = emptyList<TaskEntry>()

    override fun onCreate() = loadData()
    override fun onDataSetChanged() = loadData()
    override fun onDestroy() {}

    private fun loadData() {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val payload = prefs.getString("matrix_payload", null)
        tasks = if (!payload.isNullOrBlank()) {
            try {
                val arr = JSONObject(payload).optJSONArray(quadrantKey) ?: JSONArray()
                (0 until arr.length()).map { i ->
                    val item = arr.getJSONObject(i)
                    TaskEntry(item.optString("id", ""), item.optString("title", ""))
                }
            } catch (_: Exception) {
                emptyList()
            }
        } else {
            emptyList()
        }
    }

    override fun getCount() = tasks.size

    override fun getViewAt(position: Int): RemoteViews {
        val task = tasks.getOrNull(position)
            ?: return RemoteViews(context.packageName, R.layout.widget_task_item)
        val rv = RemoteViews(context.packageName, R.layout.widget_task_item)
        rv.setTextViewText(R.id.task_title, task.title)
        if (task.id.isNotEmpty()) {
            val fillIn = Intent().apply {
                putExtra(EisenhowerAppWidgetProvider.EXTRA_TASK_ID, task.id)
            }
            rv.setOnClickFillInIntent(R.id.task_check, fillIn)
        }
        return rv
    }

    override fun getLoadingView() = null
    override fun getViewTypeCount() = 1
    override fun getItemId(position: Int) = position.toLong()
    override fun hasStableIds() = false
}
