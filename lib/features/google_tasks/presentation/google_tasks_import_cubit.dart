import 'package:eisenhower_matrix_app/features/tasks/presentation/helpers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/google_tasks_repository.dart';
import '../domain/google_task_item.dart';

part 'google_tasks_import_state.dart';

class GoogleTasksImportCubit extends Cubit<GoogleTasksImportState> {
  GoogleTasksImportCubit(this._repository)
    : super(const GoogleTasksImportState.initial());

  final GoogleTasksRepository _repository;

  Future<void> loadTasks() async {
    emit(const GoogleTasksImportState.loading());
    try {
      final tasks = await _repository.fetchIncompleteTasks();
      emit(GoogleTasksImportState.selecting(tasks: tasks));
    } catch (e) {
      emit(GoogleTasksImportState.error(e.toString()));
    }
  }

  void toggleSelection(GoogleTaskItem task) {
    final current = state;
    if (current.status != GoogleTasksImportStatus.selecting) return;
    final selected = List<GoogleTaskItem>.from(current.selected);
    if (selected.any((t) => t.id == task.id)) {
      selected.removeWhere((t) => t.id == task.id);
    } else {
      selected.add(task);
    }
    emit(
      GoogleTasksImportState.selecting(
        tasks: current.tasks,
        selected: selected,
      ),
    );
  }

  void toggleSelectAll(List<GoogleTaskItem> listTasks) {
    final current = state;
    if (current.status != GoogleTasksImportStatus.selecting) return;
    final selected = List<GoogleTaskItem>.from(current.selected);
    final allSelected = listTasks.every((t) => selected.any((s) => s.id == t.id));
    if (allSelected) {
      selected.removeWhere((s) => listTasks.any((t) => t.id == s.id));
    } else {
      for (final task in listTasks) {
        if (!selected.any((s) => s.id == task.id)) {
          selected.add(task);
        }
      }
    }
    emit(
      GoogleTasksImportState.selecting(
        tasks: current.tasks,
        selected: selected,
      ),
    );
  }

  void proceedToAssignment() {
    final current = state;
    if (current.selected.isEmpty) return;
    emit(
      GoogleTasksImportState.assigning(
        tasks: current.tasks,
        selected: current.selected,
        assignments: const {},
      ),
    );
  }

  void assignQuadrant(GoogleTaskItem task, EisenhowerQuadrant quadrant) {
    final current = state;
    if (current.status != GoogleTasksImportStatus.assigning) return;
    final assignments = Map<String, EisenhowerQuadrant>.from(
      current.assignments,
    )..[task.id] = quadrant;
    emit(
      GoogleTasksImportState.assigning(
        tasks: current.tasks,
        selected: current.selected,
        assignments: assignments,
      ),
    );
  }

  bool get allAssigned =>
      state.selected.isNotEmpty &&
      state.selected.every((t) => state.assignments.containsKey(t.id));
}
