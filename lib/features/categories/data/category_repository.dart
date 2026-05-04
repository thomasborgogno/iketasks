import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../domain/task_category.dart';

class CategoryRepository {
  CategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _categoriesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Stream<List<TaskCategory>> watchCategories(String uid) {
    return _categoriesRef(uid)
        .orderBy('order')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskCategory.fromDoc(doc)).toList(),
        );
  }

  Future<void> createCategory(
    String uid,
    String name, {
    String? emoji,
    int order = 0,
  }) async {
    final now = DateTime.now();
    final category = TaskCategory(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      order: order,
      createdAt: now,
      updatedAt: now,
    );

    await _categoriesRef(uid).doc(category.id).set(category.toMap());
  }

  Future<void> reorderCategories(
    String uid,
    List<TaskCategory> categories,
  ) async {
    final batch = _firestore.batch();
    for (var i = 0; i < categories.length; i++) {
      batch.update(
        _categoriesRef(uid).doc(categories[i].id),
        {'order': i},
      );
    }
    await batch.commit();
  }

  Future<void> updateCategory(
    String uid,
    String categoryId, {
    required String name,
    String? emoji,
  }) async {
    final data = <String, dynamic>{'name': name, 'updatedAt': Timestamp.now()};
    if (emoji != null && emoji.isNotEmpty) {
      data['emoji'] = emoji;
    } else {
      data['emoji'] = FieldValue.delete();
    }
    await _categoriesRef(uid).doc(categoryId).update(data);
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    final tasksRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks');

    final tasksInCategory = await tasksRef
        .where('categoryId', isEqualTo: categoryId)
        .get();

    final batch = _firestore.batch();

    for (final doc in tasksInCategory.docs) {
      batch.update(doc.reference, {'categoryId': FieldValue.delete()});
    }

    batch.delete(_categoriesRef(uid).doc(categoryId));

    await batch.commit();
  }

  Future<void> deleteAllData(String uid) async {
    const chunkSize = 500;
    final ref = _categoriesRef(uid);
    QuerySnapshot<Map<String, dynamic>> snapshot;
    do {
      snapshot = await ref.limit(chunkSize).get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snapshot.docs.length == chunkSize);
  }
}
