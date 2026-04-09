import 'dart:convert';

import 'package:eisenhower_matrix_app/features/tasks/presentation/helpers.dart';
import 'package:home_widget/home_widget.dart';

import '../tasks/domain/task_item.dart';
import 'minimal_widget_settings.dart';

class MinimalWidgetSyncService {
  static const _androidProvider = 'MinimalWidgetReceiver';
  static const _settingsKey = 'minimal_widget_settings';
  static const _tasksKey = 'minimal_widget_tasks';

  MinimalWidgetSettings _currentSettings = MinimalWidgetSettings.defaults();

  Future<void> initialize() async {
    final raw = await HomeWidget.getWidgetData<String>(_settingsKey);
    if (raw != null && raw.isNotEmpty) {
      _currentSettings = MinimalWidgetSettings.fromJsonString(raw);
    }
  }

  MinimalWidgetSettings get currentSettings => _currentSettings;

  Future<void> saveSettings(MinimalWidgetSettings settings) async {
    _currentSettings = settings;
    await HomeWidget.saveWidgetData<String>(
      _settingsKey,
      settings.toJsonString(),
    );
    await HomeWidget.updateWidget(androidName: _androidProvider);
  }

  Future<void> pushTasks(List<TaskItem> tasks) async {
    // Get tasks from priority quadrant (q1)
    var priorityTasks = tasks
        .where((t) => t.quadrant == EisenhowerQuadrant.importantUrgent)
        .toList();

    // If fallback is enabled and priority is empty, get from other quadrants
    if (_currentSettings.fallbackToNextQuadrants && priorityTasks.isEmpty) {
      // Try q2 first (Plan)
      priorityTasks = tasks
          .where((t) => t.quadrant == EisenhowerQuadrant.importantNotUrgent)
          .toList();

      // If still empty, try q3 (Delegate)
      if (priorityTasks.isEmpty) {
        priorityTasks = tasks
            .where((t) => t.quadrant == EisenhowerQuadrant.notImportantUrgent)
            .toList();
      }

      // If still empty, try q4 (Eliminate)
      if (priorityTasks.isEmpty) {
        priorityTasks = tasks
            .where(
              (t) => t.quadrant == EisenhowerQuadrant.notImportantNotUrgent,
            )
            .toList();
      }
    }

    // Limit to the configured number of tasks
    final limitedTasks = priorityTasks.take(5).toList();

    // Convert to simple list of titles — Android receiver uses taskCount from settings to control display
    final taskTitles = limitedTasks.map((t) => t.title).toList();

    await HomeWidget.saveWidgetData<String>(_tasksKey, jsonEncode(taskTitles));
    await HomeWidget.updateWidget(androidName: _androidProvider);
  }
}
