part of 'google_tasks_import_cubit.dart';

enum GoogleTasksImportStatus { initial, loading, selecting, assigning, error }

class GoogleTasksImportState extends Equatable {
  const GoogleTasksImportState._({
    required this.status,
    this.tasks = const [],
    this.selected = const [],
    this.assignments = const {},
    this.errorMessage,
  });

  const GoogleTasksImportState.initial()
    : this._(status: GoogleTasksImportStatus.initial);
  const GoogleTasksImportState.loading()
    : this._(status: GoogleTasksImportStatus.loading);
  const GoogleTasksImportState.selecting({
    required List<GoogleTaskItem> tasks,
    List<GoogleTaskItem> selected = const [],
  }) : this._(
         status: GoogleTasksImportStatus.selecting,
         tasks: tasks,
         selected: selected,
       );
  const GoogleTasksImportState.assigning({
    required List<GoogleTaskItem> tasks,
    required List<GoogleTaskItem> selected,
    required Map<String, EisenhowerQuadrant> assignments,
  }) : this._(
         status: GoogleTasksImportStatus.assigning,
         tasks: tasks,
         selected: selected,
         assignments: assignments,
       );
  const GoogleTasksImportState.error(String message)
    : this._(status: GoogleTasksImportStatus.error, errorMessage: message);

  final GoogleTasksImportStatus status;
  final List<GoogleTaskItem> tasks;
  final List<GoogleTaskItem> selected;
  final Map<String, EisenhowerQuadrant> assignments;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    status,
    tasks,
    selected,
    assignments,
    errorMessage,
  ];
}
