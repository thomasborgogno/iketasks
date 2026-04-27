import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iketasks/features/tasks/presentation/helpers.dart';
import 'package:uuid/uuid.dart';

import '../domain/task_item.dart';

class TaskRepository {
  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _tasksRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<TaskItem>> watchTasks(String uid) {
    return _tasksRef(uid)
        .orderBy('title')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskItem.fromDoc(doc)).toList(),
        );
  }

  Stream<List<TaskItem>> watchCompletedTasks(String uid) {
    return _tasksRef(uid)
        .where('completed', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskItem.fromDoc(doc)).toList(),
        );
  }

  Future<void> upsertTask(String uid, TaskItem task) async {
    await _tasksRef(
      uid,
    ).doc(task.id).set(task.toMap(), SetOptions(merge: true));
  }

  Future<void> createTask(
    String uid, {
    required String title,
    required EisenhowerQuadrant quadrant,
    String? description,
    DateTime? dueDate,
    DateTime? showFromDate,
    String? categoryId,
  }) async {
    final now = DateTime.now();
    final task = TaskItem(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      showFromDate: showFromDate,
      categoryId: categoryId,
      quadrant: quadrant,
      completed: false,
      createdAt: now,
      updatedAt: now,
    );

    await upsertTask(uid, task);
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _tasksRef(uid).doc(taskId).delete();
  }

  Future<void> deleteTasks(String uid, Iterable<String> taskIds) async {
    final ids = taskIds.toSet();
    if (ids.isEmpty) return;

    final batch = _firestore.batch();
    for (final taskId in ids) {
      batch.delete(_tasksRef(uid).doc(taskId));
    }
    await batch.commit();
  }
}
