package com.eisenhower.matrix.todo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions

class EisenhowerAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            try {
                val views = buildRemoteViews(context)
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (_: Exception) {}
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_TOGGLE_TASK) {
            val taskId = intent.getStringExtra(EXTRA_TASK_ID) ?: return
            toggleTaskInFirestore(context, taskId)
        }
    }

    companion object {
        private const val PREFS = "HomeWidgetPreferences"
        const val ACTION_TOGGLE_TASK = "com.eisenhower.matrix.TOGGLE_TASK"
        const val EXTRA_TASK_ID = "task_id"
        const val EXTRA_OPEN_ADD_TASK = "open_add_task"

        private val QUADRANTS = listOf(
            Triple("q1", R.id.q1_list, R.id.q1_empty),
            Triple("q2", R.id.q2_list, R.id.q2_empty),
            Triple("q3", R.id.q3_list, R.id.q3_empty),
            Triple("q4", R.id.q4_list, R.id.q4_empty),
        )

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, EisenhowerAppWidgetProvider::class.java),
            )
            ids.forEach { id ->
                manager.updateAppWidget(id, buildRemoteViews(context))
            }
            QUADRANTS.forEach { (_, listId, _) ->
                manager.notifyAppWidgetViewDataChanged(ids, listId)
            }
        }

        private fun toggleTaskInFirestore(context: Context, taskId: String) {
            try { FirebaseApp.initializeApp(context) } catch (_: Exception) {}
            val uid = FirebaseAuth.getInstance().currentUser?.uid ?: return
            val db = FirebaseFirestore.getInstance()
            val taskRef = db.collection("users").document(uid).collection("tasks").document(taskId)
            taskRef.get().addOnSuccessListener { doc: DocumentSnapshot ->
                if (doc.exists()) {
                    val completed = doc.getBoolean("completed") ?: false
                    taskRef.set(
                        mapOf(
                            "completed" to !completed,
                            "updatedAt" to com.google.firebase.Timestamp.now(),
                        ),
                        SetOptions.merge(),
                    ).addOnSuccessListener { updateAll(context) }
                }
            }
        }

        private fun buildRemoteViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.eisenhower_widget)

            val toggleTemplate = Intent(context, EisenhowerAppWidgetProvider::class.java).apply {
                action = ACTION_TOGGLE_TASK
            }
            val togglePending = PendingIntent.getBroadcast(
                context, 0, toggleTemplate,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )

            QUADRANTS.forEach { (key, listId, emptyId) ->
                val serviceIntent = Intent(context, EisenhowerWidgetRemoteViewsService::class.java).apply {
                    data = Uri.parse("eisenhower://widget/$key")
                    putExtra("quadrant_key", key)
                }
                views.setRemoteAdapter(listId, serviceIntent)
                views.setEmptyView(listId, emptyId)
                views.setPendingIntentTemplate(listId, togglePending)
            }

            // Add task button -> open app
            val addIntent = Intent(context, MainActivity::class.java).apply {
                putExtra(EXTRA_OPEN_ADD_TASK, true)
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            }
            views.setOnClickPendingIntent(
                R.id.btn_add_widget,
                PendingIntent.getActivity(
                    context, 1000, addIntent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                ),
            )

            // Root tap -> open app
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            }
            views.setOnClickPendingIntent(
                R.id.widget_root,
                PendingIntent.getActivity(
                    context, 0, launchIntent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                ),
            )

            return views
        }
    }
}
