package com.bortho.iketasks

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.updateAll
import com.google.firebase.FirebaseApp
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import com.google.firebase.Timestamp
import kotlinx.coroutines.tasks.await

class ToggleTaskActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val taskId = parameters[taskIdKey] ?: return

        try { FirebaseApp.initializeApp(context) } catch (_: Exception) {}
        val uid = FirebaseAuth.getInstance().currentUser?.uid ?: return
        val db = FirebaseFirestore.getInstance()
        val taskRef = db.collection("users").document(uid)
            .collection("tasks").document(taskId)

        val doc = taskRef.get().await()
        if (doc.exists()) {
            val completed = doc.getBoolean("completed") ?: false
            taskRef.set(
                mapOf(
                    "completed" to !completed,
                    "updatedAt" to Timestamp.now(),
                ),
                SetOptions.merge(),
            ).await()
        }

        EisenhowerGlanceWidget().updateAll(context)
    }
}
