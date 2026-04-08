import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eisenhower_matrix_app/features/tasks/presentation/helpers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/notifications/notification_service.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/task_item.dart';
import '../../widget/widget_sync_service.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit(
    this._repository,
    this._widgetSyncService,
    this._notificationService,
  ) : super(const TaskState.initial());

  final TaskRepository _repository;
  final WidgetSyncService _widgetSyncService;
  final NotificationService _notificationService;

  StreamSubscription<List<TaskItem>>? _taskSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  String? _uid;

  static bool _completedWithinLastHour(DateTime dt) {
    return DateTime.now().difference(dt) <= const Duration(hours: 1);
  }

  Future<void> bindUser(String uid) async {
    _uid = uid;
    emit(const TaskState.loading());

    await _taskSubscription?.cancel();
    _taskSubscription = _repository.watchTasks(uid).listen((tasks) async {
      int sortByDueDate(TaskItem a, TaskItem b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      }

      final incomplete = tasks.where((t) => !t.completed).toList()
        ..sort(sortByDueDate);
      final recentlyCompleted =
          tasks
              .where(
                (t) => t.completed && _completedWithinLastHour(t.updatedAt),
              )
              .toList()
            ..sort(sortByDueDate);
      final visible = [...incomplete, ...recentlyCompleted];

      final allIncompleteForWidget = tasks.where((t) => !t.completed).toList();
      emit(TaskState.loaded(visible));
      await _widgetSyncService.pushTasks(allIncompleteForWidget);
      await _notificationService.updatePriorityNotification(
        allIncompleteForWidget,
      );
    }, onError: (error) => emit(TaskState.error(error.toString())));

    await _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      _,
    ) async {
      if (state.status == TaskStatus.loaded && state.tasks.isNotEmpty) {
        await _widgetSyncService.pushTasks(state.tasks);
      }
    });
  }

  Future<void> createTask({
    required String title,
    required EisenhowerQuadrant quadrant,
    String? description,
    DateTime? dueDate,
    String? categoryId,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _repository.createTask(
      uid,
      title: title,
      quadrant: quadrant,
      description: description,
      dueDate: dueDate,
      categoryId: categoryId,
    );
  }

  Future<void> updateTask(TaskItem task) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.upsertTask(uid, task.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> toggleTask(TaskItem task) async {
    await updateTask(task.copyWith(completed: !task.completed));
  }

  Future<void> moveTask(TaskItem task, EisenhowerQuadrant quadrant) async {
    await updateTask(task.copyWith(quadrant: quadrant));
  }

  Future<void> deleteTask(String taskId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.deleteTask(uid, taskId);
  }

  Future<void> deleteTasks(Iterable<String> taskIds) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.deleteTasks(uid, taskIds);
  }

  @override
  Future<void> close() async {
    await _taskSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
