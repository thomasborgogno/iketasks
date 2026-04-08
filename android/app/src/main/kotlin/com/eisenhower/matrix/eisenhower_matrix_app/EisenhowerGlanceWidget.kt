package com.eisenhower.matrix.todo

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.appwidget.cornerRadius
import androidx.glance.layout.wrapContentHeight
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import org.json.JSONArray
import org.json.JSONObject

val taskIdKey = ActionParameters.Key<String>("task_id")
const val EXTRA_OPEN_ADD_TASK = "open_add_task"

private data class TaskEntry(val id: String, val title: String)

private data class QuadrantSpec(
    val key: String,
    val label: String,
    val color: Color,
)

private val QUADRANTS = listOf(
    QuadrantSpec("q1", "Priorità", Color(0xFFD7263D)),
    QuadrantSpec("q2", "Pianifica", Color(0xFF1B998B)),
    QuadrantSpec("q3", "Delega", Color(0xFFF4A261)),
    QuadrantSpec("q4", "Elimina", Color(0xFF457B9D)),
)

private val backgroundColor = Color(0xFF1C1B1F)

class EisenhowerGlanceWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val tasks = loadTasks(context)
        provideContent {
            GlanceTheme {
                WidgetContent(tasks = tasks, context = context)
            }
        }
    }

    private fun loadTasks(context: Context): Map<String, List<TaskEntry>> {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val payload = prefs.getString("matrix_payload", null)
        if (payload.isNullOrBlank()) return emptyMap()
        return try {
            val json = JSONObject(
                payload)
            QUADRANTS.associate { spec ->
                val arr: JSONArray = json.optJSONArray(spec.key) ?: JSONArray()
                spec.key to (0 until arr.length()).map { i ->
                    val item = arr.getJSONObject(i)
                    TaskEntry(
                        id = item.optString("id", ""),
                        title = item.optString("title", ""),
                    )
                }
            }
        } catch (_: Exception) {
            emptyMap()
        }
    }
}

@Composable
private fun WidgetContent(tasks: Map<String, List<TaskEntry>>, context: Context) {
    val addIntent = Intent(context, MainActivity::class.java).apply {
        putExtra(EXTRA_OPEN_ADD_TASK, true)
        flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    }

    val openAppIntent = Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    }

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(backgroundColor))
            .clickable(actionStartActivity(openAppIntent)),
        contentAlignment = Alignment.BottomEnd,
    ) {
        // Main content
        Column(modifier = GlanceModifier.fillMaxSize()) {
        // Header row
        // Row(
        //     modifier = GlanceModifier
        //         .fillMaxWidth()
        //         .height(48.dp)
        //         .background(ColorProvider(Color(0xFF2B2930)))
        //         .padding(horizontal = 12.dp),
        //     verticalAlignment = Alignment.CenterVertically,
        // ) {
        //     Text(
        //         text = "Eisenhower",
        //         style = TextStyle(
        //             color = ColorProvider(Color.White),
        //             fontSize = 14.sp,
        //             fontWeight = FontWeight.Bold,
        //         ),
        //     )
        // }

        Column(modifier = GlanceModifier.wrapContentHeight().fillMaxWidth()) {
            QuadrantSection(
                modifier = GlanceModifier.wrapContentHeight().fillMaxWidth(),
                spec = QUADRANTS[0],
                taskList = tasks[QUADRANTS[0].key] ?: emptyList(),
            )
            Spacer(modifier = GlanceModifier.height(20.dp).fillMaxWidth())
            QuadrantSection(
                modifier = GlanceModifier.wrapContentHeight().fillMaxWidth(),
                spec = QUADRANTS[1],
                taskList = tasks[QUADRANTS[1].key] ?: emptyList(),
            )
            Spacer(modifier = GlanceModifier.height(20.dp).fillMaxWidth())
            QuadrantSection(
                modifier = GlanceModifier.wrapContentHeight().fillMaxWidth(),
                spec = QUADRANTS[2],
                taskList = tasks[QUADRANTS[2].key] ?: emptyList(),
            )
            // Spacer(modifier = GlanceModifier.height(20.dp).fillMaxWidth())
            // QuadrantSection(
            //     modifier = GlanceModifier.wrapContentHeight().fillMaxWidth(),
            //     spec = QUADRANTS[3],
            //     taskList = tasks[QUADRANTS[3].key] ?: emptyList(),
            // )
        }
    }

        // FAB overlay — bottom-right
        Box(modifier = GlanceModifier.padding(bottom = 12.dp, end = 12.dp)) {
            Box(
                modifier = GlanceModifier
                    .width(52.dp)
                    .height(52.dp)
                    .cornerRadius(26.dp)
                    .background(ColorProvider(Color(0xFF6750A4)))
                    .clickable(actionStartActivity(addIntent)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "+",
                    style = TextStyle(
                        color = ColorProvider(Color.White),
                        fontSize = 32.sp,
                    ),
                )
            }
        }
    } // end root Box
}

@Composable
private fun QuadrantSection(
    modifier: GlanceModifier,
    spec: QuadrantSpec,
    taskList: List<TaskEntry>,
) {
    Column(modifier = modifier) {
        // Quadrant label header
        Row(
            modifier = GlanceModifier
                .fillMaxWidth()
                .wrapContentHeight()
                .background(ColorProvider(spec.color.copy(alpha = 0.25f)))
                .padding(horizontal = 10.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                modifier = GlanceModifier
                    .width(3.dp)
                    .height(14.dp)
                    .background(ColorProvider(spec.color)),
            ) {}
            Spacer(modifier = GlanceModifier.width(6.dp))
            Text(
                text = spec.label,
                style = TextStyle(
                    color = ColorProvider(spec.color),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                ),
                maxLines = 1,
            )
        }

        // Task list
        if (taskList.isEmpty()) {
            Box(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .height(40.dp)
                    .padding(6.dp),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "Nessuna attività",
                    style = TextStyle(
                        color = ColorProvider(Color(0x99FFFFFF)),
                        fontSize = 10.sp,
                    ),
                )
            }
        } else {
            Column(modifier = GlanceModifier.fillMaxWidth().wrapContentHeight()) {
                taskList.forEach { task ->
                    TaskRow(task = task, accentColor = spec.color)
                }
            }
        }
    }
}

@Composable
private fun TaskRow(task: TaskEntry, accentColor: Color) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .wrapContentHeight()
            .padding(horizontal = 10.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Circle check indicator
        Box(
            modifier = GlanceModifier
                .width(16.dp)
                .height(16.dp)
                .cornerRadius(8.dp)
                .background(ColorProvider(accentColor.copy(alpha = 0.7f)))
                .clickable(
                    actionRunCallback<ToggleTaskActionCallback>(
                        actionParametersOf(taskIdKey to task.id),
                    ),
                ),
            contentAlignment = Alignment.Center,
        ) {
            // Inner: "buco" che simula il contorno
            Box(
                modifier = GlanceModifier
                    .width(12.dp)
                    .height(12.dp)
                    .cornerRadius(6.dp)
                    .background(ColorProvider(backgroundColor.copy(alpha = 0.9f))), // stesso bg del widget
            ) {}
        }
        Spacer(modifier = GlanceModifier.width(10.dp))
        Text(
            text = task.title,
            style = TextStyle(
                color = ColorProvider(Color(0xDDFFFFFF)),
                fontSize = 13.sp,
            ),
            maxLines = 2,
        )
    }
}
