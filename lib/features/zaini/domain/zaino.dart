import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Zaino extends Equatable {
  const Zaino({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.emoji,
    this.googleTaskListId,
    this.categoryOrder = const [],
  });

  final String id;
  final String name;
  final String? emoji;
  final String? googleTaskListId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Display order of category names chosen by the user (via the up/down
  /// carets). Categories not listed here are appended alphabetically after
  /// the ones that are.
  final List<String> categoryOrder;

  Zaino copyWith({
    String? name,
    String? emoji,
    String? googleTaskListId,
    List<String>? categoryOrder,
    bool clearEmoji = false,
    bool clearGoogleTaskListId = false,
  }) {
    return Zaino(
      id: id,
      name: name ?? this.name,
      emoji: clearEmoji ? null : (emoji ?? this.emoji),
      googleTaskListId: clearGoogleTaskListId
          ? null
          : (googleTaskListId ?? this.googleTaskListId),
      categoryOrder: categoryOrder ?? this.categoryOrder,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'googleTaskListId': googleTaskListId,
      'categoryOrder': categoryOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Zaino.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Zaino(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      emoji: data['emoji'] as String?,
      googleTaskListId: data['googleTaskListId'] as String?,
      categoryOrder: List<String>.from(
        (data['categoryOrder'] as List<dynamic>?) ?? [],
      ),
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
      updatedAt: ((data['updatedAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    emoji,
    googleTaskListId,
    categoryOrder,
    createdAt,
    updatedAt,
  ];
}
