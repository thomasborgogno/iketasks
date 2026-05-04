import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskCategory extends Equatable {
  const TaskCategory({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.emoji,
    this.order = 0,
  });

  final String id;
  final String name;
  final String? emoji;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int order;

  TaskCategory copyWith({
    String? id,
    String? name,
    String? emoji,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? order,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (emoji != null) 'emoji': emoji,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TaskCategory.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TaskCategory(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      emoji: data['emoji'] as String?,
      order: (data['order'] as int?) ?? 0,
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
      updatedAt: ((data['updatedAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, order, createdAt, updatedAt];
}
