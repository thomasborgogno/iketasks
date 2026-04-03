import 'dart:convert';

import 'package:eisenhower_matrix_app/features/tasks/presentation/helpers.dart';
import 'package:home_widget/home_widget.dart';

import '../tasks/domain/task_item.dart';

class WidgetSyncService {
  static const _androidProvider = 'EisenhowerGlanceReceiver';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.eisenhower.matrix');
  }

  Future<void> pushTasks(List<TaskItem> tasks) async {
    final byQuadrant = <String, List<Map<String, dynamic>>>{
      'q1': [],
      'q2': [],
      'q3': [],
      'q4': [],
    };

    for (final task in tasks) {
      final list = byQuadrant[task.quadrant.value]!;
      list.add({
        'id': task.id,
        'title': task.title,
        'completed': task.completed,
      });
    }

    await HomeWidget.saveWidgetData<String>(
      'matrix_payload',
      jsonEncode(byQuadrant),
    );
    await HomeWidget.updateWidget(androidName: _androidProvider);
  }
}
