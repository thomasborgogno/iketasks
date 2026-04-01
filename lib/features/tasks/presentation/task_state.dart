part of 'task_cubit.dart';

enum TaskStatus { initial, loading, loaded, error }

class TaskState extends Equatable {
  const TaskState._({
    required this.status,
    this.tasks = const [],
    this.errorMessage,
  });

  const TaskState.initial() : this._(status: TaskStatus.initial);
  const TaskState.loading() : this._(status: TaskStatus.loading);
  const TaskState.loaded(List<TaskItem> tasks)
      : this._(status: TaskStatus.loaded, tasks: tasks);
  const TaskState.error(String message)
      : this._(status: TaskStatus.error, errorMessage: message);

  final TaskStatus status;
  final List<TaskItem> tasks;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, tasks, errorMessage];
}
