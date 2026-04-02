import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/task_repository.dart';
import '../domain/task_item.dart';

part 'completed_tasks_state.dart';

class CompletedTasksCubit extends Cubit<CompletedTasksState> {
  CompletedTasksCubit(this._repository)
    : super(const CompletedTasksState.initial());

  final TaskRepository _repository;
  StreamSubscription<List<TaskItem>>? _subscription;
  String? _uid;

  void bind(String uid) {
    _uid = uid;
    emit(const CompletedTasksState.loading());
    _subscription?.cancel();
    _subscription = _repository
        .watchCompletedTasks(uid)
        .listen(
          (tasks) => emit(CompletedTasksState.loaded(tasks)),
          onError: (error) => emit(CompletedTasksState.error(error.toString())),
        );
  }

  Future<void> uncompleteTask(TaskItem task) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.upsertTask(uid, task.copyWith(completed: false));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
