import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum EisenhowerQuadrant {
  importantUrgent,
  importantNotUrgent,
  notImportantUrgent,
  notImportantNotUrgent,
}

extension EisenhowerQuadrantX on EisenhowerQuadrant {
  String get label {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return 'Importante, urgente';
      case EisenhowerQuadrant.importantNotUrgent:
        return 'Importante, non urgente';
      case EisenhowerQuadrant.notImportantUrgent:
        return 'Non importante, urgente';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return 'Non importante, non urgente';
    }
  }

  String get cardTitle {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return 'Priorità';
      case EisenhowerQuadrant.importantNotUrgent:
        return 'Pianifica';
      case EisenhowerQuadrant.notImportantUrgent:
        return 'Delega';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return 'Elimina';
    }
  }

  String get value {
    switch (this) {
      case EisenhowerQuadrant.importantUrgent:
        return 'q1';
      case EisenhowerQuadrant.importantNotUrgent:
        return 'q2';
      case EisenhowerQuadrant.notImportantUrgent:
        return 'q3';
      case EisenhowerQuadrant.notImportantNotUrgent:
        return 'q4';
    }
  }

  static EisenhowerQuadrant fromValue(String value) {
    switch (value) {
      case 'q1':
        return EisenhowerQuadrant.importantUrgent;
      case 'q2':
        return EisenhowerQuadrant.importantNotUrgent;
      case 'q3':
        return EisenhowerQuadrant.notImportantUrgent;
      default:
        return EisenhowerQuadrant.notImportantNotUrgent;
    }
  }
}

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
    this.categoryId,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? categoryId;
  final EisenhowerQuadrant quadrant;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskItem copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? categoryId,
    EisenhowerQuadrant? quadrant,
    bool? completed,
    DateTime? updatedAt,
    bool clearDueDate = false,
    bool clearCategory = false,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
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
    categoryId,
    quadrant,
    completed,
    createdAt,
    updatedAt,
  ];
}
