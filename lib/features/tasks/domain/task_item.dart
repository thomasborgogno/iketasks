import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iketasks/features/tasks/presentation/helpers.dart';
import 'package:equatable/equatable.dart';

class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.title,
    required this.quadrant,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.dueDate,
    this.showFromDate,
    this.categoryId,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final DateTime? showFromDate;
  final String? categoryId;
  final EisenhowerQuadrant quadrant;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskItem copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? showFromDate,
    String? categoryId,
    EisenhowerQuadrant? quadrant,
    bool? completed,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearDueDate = false,
    bool clearShowFromDate = false,
    bool clearCategory = false,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      showFromDate: clearShowFromDate
          ? null
          : (showFromDate ?? this.showFromDate),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      quadrant: quadrant ?? this.quadrant,
      completed: completed ?? this.completed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'showFromDate': showFromDate == null
          ? null
          : Timestamp.fromDate(showFromDate!),
      'categoryId': categoryId,
      'quadrant': quadrant.value,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TaskItem(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: data['description'] as String?,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      showFromDate: (data['showFromDate'] as Timestamp?)?.toDate(),
      categoryId: data['categoryId'] as String?,
      quadrant: EisenhowerQuadrantX.fromValue(
        (data['quadrant'] as String?) ?? 'q1',
      ),
      completed: (data['completed'] as bool?) ?? false,
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
      updatedAt: ((data['updatedAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    showFromDate,
    categoryId,
    quadrant,
    completed,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Task $title : {\nid: $id, title: $title, description: $description, \ndueDate: $dueDate, categoryId: $categoryId, quadrant: $quadrant, completed: $completed, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
