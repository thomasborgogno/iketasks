part of 'completed_tasks_cubit.dart';

enum CompletedTasksStatus { initial, loading, loaded, error }

class CompletedTasksState extends Equatable {
  const CompletedTasksState._({
    required this.status,
    this.tasks = const [],
    this.errorMessage,
  });

  const CompletedTasksState.initial()
    : this._(status: CompletedTasksStatus.initial);
  const CompletedTasksState.loading()
    : this._(status: CompletedTasksStatus.loading);
  const CompletedTasksState.loaded(List<TaskItem> tasks)
    : this._(status: CompletedTasksStatus.loaded, tasks: tasks);
  const CompletedTasksState.error(String message)
    : this._(status: CompletedTasksStatus.error, errorMessage: message);

  final CompletedTasksStatus status;
  final List<TaskItem> tasks;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, tasks, errorMessage];
}
