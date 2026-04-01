import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskCategory extends Equatable {
  const TaskCategory({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.emoji,
  });

  final String id;
  final String name;
  final String? emoji;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (emoji != null) 'emoji': emoji,
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
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
      updatedAt: ((data['updatedAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, createdAt, updatedAt];
}
