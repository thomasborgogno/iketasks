package com.eisenhower.matrix.todo

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.datastore.core.DataStore
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentHeight
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

val taskIdKey = ActionParameters.Key<String>("task_id")
const val EXTRA_OPEN_ADD_TASK = "open_add_task"
const val EXTRA_OPEN_WIDGET_SETTINGS = "open_widget_settings"

data class TaskEntry(val id: String, val title: String)

data class QuadrantSpec(
    val key: String,
    val label: String,
    val color: Color,
)

data class AppearanceSpec(
    val bgColor: Color,
    val labelFontSize: TextUnit,
    val taskFontSize: TextUnit,
    val emptyFontSize: TextUnit,
    val visibleQuadrants: Set<String>,
    val darkText: Boolean,
)

data class WidgetState(
    val tasks: Map<String, List<TaskEntry>>,
    val appearance: AppearanceSpec,
)

val ALL_QUADRANTS = listOf(
    QuadrantSpec("q1", "Priorità", Color(0xFFD7263D)),
    QuadrantSpec("q2", "Pianifica", Color(0xFF1B998B)),
    QuadrantSpec("q3", "Delega", Color(0xFFF4A261)),
    QuadrantSpec("q4", "Elimina", Color(0xFF457B9D)),
)

val defaultBackgroundColor = Color(0xFF1C1B1F)

fun defaultAppearance() = AppearanceSpec(
    bgColor = defaultBackgroundColor,
    labelFontSize = 13.sp,
    taskFontSize = 13.sp,
    emptyFontSize = 10.sp,
    visibleQuadrants = setOf("q1", "q2", "q3"),
    darkText = false,
)

class EisenhowerDataStore(private val context: Context) : DataStore<WidgetState> {
    override val data: Flow<WidgetState>
        get() = flow { emit(readState()) }

    override suspend fun updateData(transform: suspend (t: WidgetState) -> WidgetState): WidgetState {
        throw UnsupportedOperationException("EisenhowerDataStore is a read-only proxy")
    }

    private fun readState(): WidgetState {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        return WidgetState(
            tasks = parseTasks(prefs.getString("matrix_payload", null)),
            appearance = parseAppearance(prefs.getString("widget_appearance", null)),
        )
    }

    private fun parseTasks(payload: String?): Map<String, List<TaskEntry>> {
        if (payload.isNullOrBlank()) return emptyMap()
        return try {
            val json = JSONObject(payload)
            ALL_QUADRANTS.associate { spec ->
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

    private fun parseAppearance(raw: String?): AppearanceSpec {
        if (raw.isNullOrBlank()) return defaultAppearance()
        return try {
            val json = JSONObject(raw)

            val bgHex = json.optString("bg_color", "1c1b1f")
            val bgRgb = bgHex.toLong(16).toInt()
            val bgAlpha = json.optInt("bg_alpha", 255)
            val bgArgb = (bgAlpha shl 24) or (bgRgb and 0x00FFFFFF)
            val bgColor = Color(bgArgb.toLong() and 0xFFFFFFFFL)

            val textSizeStr = json.optString("text_size", "medium")
            val (labelSp, taskSp, emptySp) = when (textSizeStr) {
                "small" -> Triple(11.sp, 11.sp, 9.sp)
                "large" -> Triple(15.sp, 15.sp, 12.sp)
                else    -> Triple(13.sp, 13.sp, 10.sp)
            }

            val arr = json.optJSONArray("visible_quadrants")
            val visible = if (arr != null) {
                (0 until arr.length()).map { arr.getString(it) }.toSet()
            } else {
                setOf("q1", "q2", "q3")
            }

            val darkText = json.optString("text_color", "white") == "black"

            AppearanceSpec(
                bgColor = bgColor,
                labelFontSize = labelSp,
                taskFontSize = taskSp,
                emptyFontSize = emptySp,
                visibleQuadrants = visible,
                darkText = darkText,
            )
        } catch (_: Exception) {
            defaultAppearance()
        }
    }
}

class EisenhowerStateDefinition : GlanceStateDefinition<WidgetState> {
    override suspend fun getDataStore(context: Context, fileKey: String): DataStore<WidgetState> =
        EisenhowerDataStore(context)

    override fun getLocation(context: Context, fileKey: String): File =
        throw UnsupportedOperationException("EisenhowerDataStore does not use a file location")
}

class EisenhowerGlanceWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<WidgetState> = EisenhowerStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                val state = currentState<WidgetState>()
                WidgetContent(tasks = state.tasks, context = context, appearance = state.appearance)
            }
        }
    }
}

@Composable
private fun WidgetContent(
    tasks: Map<String, List<TaskEntry>>,
    context: Context,
    appearance: AppearanceSpec,
) {
    val addIntent = Intent(context, MainActivity::class.java).apply {
        putExtra(EXTRA_OPEN_ADD_TASK, true)
        flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    }

    val settingsIntent = Intent(context, MainActivity::class.java).apply {
        putExtra(EXTRA_OPEN_WIDGET_SETTINGS, true)
        flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    }

    val openAppIntent = Intent(context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
    }

    val visibleQuadrants = ALL_QUADRANTS.filter { it.key in appearance.visibleQuadrants }

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(appearance.bgColor))
            .clickable(actionStartActivity(openAppIntent)),
        contentAlignment = Alignment.BottomEnd,
    ) {
        // Main content
        Column(modifier = GlanceModifier.fillMaxSize()) {
            Column(modifier = GlanceModifier.wrapContentHeight().fillMaxWidth()) {
                visibleQuadrants.forEachIndexed { index, spec ->
                    if (index > 0) {
                        Spacer(modifier = GlanceModifier.height(20.dp).fillMaxWidth())
                    }
                    QuadrantSection(
                        modifier = GlanceModifier.wrapContentHeight().fillMaxWidth(),
                        spec = spec,
                        taskList = tasks[spec.key] ?: emptyList(),
                        appearance = appearance,
                    )
                }
            }
        }

        // FAB overlay — bottom-right
        val _bg = appearance.bgColor
        val fabBgColor = Color(
            red   = _bg.red   + (1f - _bg.red)   * 0.35f,
            green = _bg.green + (1f - _bg.green) * 0.35f,
            blue  = _bg.blue  + (1f - _bg.blue)  * 0.35f,
            alpha = _bg.alpha,
        )
        Row(
            modifier = GlanceModifier.padding(bottom = 12.dp, end = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Settings button — small and subtle
            Box(
                modifier = GlanceModifier
                    .width(36.dp)
                    .height(36.dp)
                    .cornerRadius(12.dp)
                    .background(ColorProvider(fabBgColor.copy(alpha = fabBgColor.alpha * 0.6f)))
                    .clickable(actionStartActivity(settingsIntent)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "⚙",
                    style = TextStyle(
                        color = ColorProvider(
                            if (appearance.darkText) Color(0x88000000) else Color(0x88FFFFFF)
                        ),
                        fontSize = 16.sp,
                    ),
                )
            }
            Spacer(modifier = GlanceModifier.width(8.dp))
            // FAB
            Box(
                modifier = GlanceModifier
                    .width(56.dp)
                    .height(56.dp)
                    .cornerRadius(16.dp)
                    .background(ColorProvider(fabBgColor))
                    .clickable(actionStartActivity(addIntent)),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = "+",
                    style = TextStyle(
                        color = ColorProvider(if (appearance.darkText) Color.Black else Color.White),
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
    appearance: AppearanceSpec,
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
                    fontSize = appearance.labelFontSize,
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
                        color = ColorProvider(
                            if (appearance.darkText) Color(0x99000000) else Color(0x99FFFFFF)
                        ),
                        fontSize = appearance.emptyFontSize,
                    ),
                )
            }
        } else {
            Column(modifier = GlanceModifier.fillMaxWidth().wrapContentHeight()) {
                taskList.forEach { task ->
                    TaskRow(task = task, accentColor = spec.color, appearance = appearance)
                }
            }
        }
    }
}

@Composable
private fun TaskRow(task: TaskEntry, accentColor: Color, appearance: AppearanceSpec) {
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
            // Inner dot to simulate an outline-only circle
            Box(
                modifier = GlanceModifier
                    .width(12.dp)
                    .height(12.dp)
                    .cornerRadius(6.dp)
                    .background(ColorProvider(appearance.bgColor.copy(alpha = 0.9f))),
            ) {}
        }
        Spacer(modifier = GlanceModifier.width(10.dp))
        Text(
            text = task.title,
            style = TextStyle(
                color = ColorProvider(
                    if (appearance.darkText) Color(0xDD000000) else Color(0xDDFFFFFF)
                ),
                fontSize = appearance.taskFontSize,
            ),
            maxLines = 2,
        )
    }
}


