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
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskCategory.fromDoc(doc)).toList());
  }

  Future<void> createCategory(String uid, String name) async {
    final now = DateTime.now();
    final category = TaskCategory(
      id: _uuid.v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    await _categoriesRef(uid).doc(category.id).set(category.toMap());
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    await _categoriesRef(uid).doc(categoryId).delete();
  }
}
