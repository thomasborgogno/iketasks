import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ZainoTag extends Equatable {
  const ZainoTag({
    required this.id,
    required this.zainoId,
    required this.name,
    required this.order,
    required this.createdAt,
  });

  final String id;
  final String zainoId;
  final String name;
  final int order;
  final DateTime createdAt;

  ZainoTag copyWith({String? name, int? order}) {
    return ZainoTag(
      id: id,
      zainoId: zainoId,
      name: name ?? this.name,
      order: order ?? this.order,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zainoId': zainoId,
      'name': name,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ZainoTag.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String zainoId,
  ) {
    final data = doc.data() ?? {};
    return ZainoTag(
      id: doc.id,
      zainoId: zainoId,
      name: (data['name'] as String?) ?? '',
      order: (data['order'] as int?) ?? 0,
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now())
          .toDate(),
    );
  }

  @override
  List<Object?> get props => [id, zainoId, name, order, createdAt];
}
