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
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskCategory.fromDoc(doc)).toList(),
        );
  }

  Future<void> createCategory(String uid, String name, {String? emoji}) async {
    final now = DateTime.now();
    final category = TaskCategory(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      createdAt: now,
      updatedAt: now,
    );

    await _categoriesRef(uid).doc(category.id).set(category.toMap());
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
}
