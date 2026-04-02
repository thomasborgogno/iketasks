import 'package:equatable/equatable.dart';

class GoogleTaskItem extends Equatable {
  const GoogleTaskItem({
    required this.id,
    required this.title,
    required this.taskListId,
    required this.taskListTitle,
    this.notes,
    this.due,
  });

  final String id;
  final String title;
  final String taskListId;
  final String taskListTitle;
  final String? notes;
  final DateTime? due;

  @override
  List<Object?> get props => [id, title, taskListId, taskListTitle, notes, due];
}
