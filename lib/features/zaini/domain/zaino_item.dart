import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ZainoItem extends Equatable {
  const ZainoItem({
    required this.id,
    required this.zainoId,
    required this.title,
    required this.completed,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.googleTaskId,
    this.categoryName,
    this.tags = const [],
  });

  final String id;
  final String zainoId;
  final String title;
  final bool completed;
  final int order;
  final String? googleTaskId;
  final String? categoryName;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ZainoItem copyWith({
    String? title,
    bool? completed,
    int? order,
    String? googleTaskId,
    String? categoryName,
    List<String>? tags,
    bool clearCategoryName = false,
    bool clearGoogleTaskId = false,
  }) {
    return ZainoItem(
      id: id,
      zainoId: zainoId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      order: order ?? this.order,
      googleTaskId: clearGoogleTaskId ? null : (googleTaskId ?? this.googleTaskId),
      categoryName: clearCategoryName ? null : (categoryName ?? this.categoryName),
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zainoId': zainoId,
      'title': title,
      'completed': completed,
      'order': order,
      'googleTaskId': googleTaskId,
      'categoryName': categoryName,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ZainoItem.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String zainoId,
  ) {
    final data = doc.data() ?? {};
    return ZainoItem(
      id: doc.id,
      zainoId: zainoId,
      title: (data['title'] as String?) ?? '',
      completed: (data['completed'] as bool?) ?? false,
      order: (data['order'] as int?) ?? 0,
      googleTaskId: data['googleTaskId'] as String?,
      categoryName: data['categoryName'] as String?,
      tags: List<String>.from((data['tags'] as List<dynamic>?) ?? []),
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
      updatedAt: ((data['updatedAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    zainoId,
    title,
    completed,
    order,
    googleTaskId,
    categoryName,
    tags,
    createdAt,
    updatedAt,
  ];
}
