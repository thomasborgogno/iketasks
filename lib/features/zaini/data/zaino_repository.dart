import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import '../domain/zaino_tag.dart';

class ZainoRepository {
  ZainoRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  // ── Collection refs ──────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _zainiRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('zaini');

  CollectionReference<Map<String, dynamic>> _itemsRef(
    String uid,
    String zainoId,
  ) => _zainiRef(uid).doc(zainoId).collection('items');

  CollectionReference<Map<String, dynamic>> _tagsRef(
    String uid,
    String zainoId,
  ) => _zainiRef(uid).doc(zainoId).collection('tags');

  // ── Zaini ────────────────────────────────────────────────────────────────────

  Stream<List<Zaino>> watchZaini(String uid) {
    return _zainiRef(uid)
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => Zaino.fromDoc(d)).toList());
  }

  Future<Zaino> createZaino(
    String uid, {
    required String name,
    String? emoji,
    String? googleTaskListId,
  }) async {
    final now = DateTime.now();
    final zaino = Zaino(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      googleTaskListId: googleTaskListId,
      createdAt: now,
      updatedAt: now,
    );
    await _zainiRef(uid).doc(zaino.id).set(zaino.toMap());
    return zaino;
  }

  Future<void> updateZaino(
    String uid,
    String zainoId, {
    String? name,
    String? emoji,
    bool clearEmoji = false,
    String? googleTaskListId,
  }) async {
    final data = <String, dynamic>{'updatedAt': Timestamp.now()};
    if (name != null) data['name'] = name;
    if (clearEmoji) {
      data['emoji'] = FieldValue.delete();
    } else if (emoji != null) {
      data['emoji'] = emoji;
    }
    if (googleTaskListId != null) data['googleTaskListId'] = googleTaskListId;
    await _zainiRef(uid).doc(zainoId).update(data);
  }

  Future<void> deleteZaino(String uid, String zainoId) async {
    // Delete all items and tags first
    await _deleteSubcollection(_itemsRef(uid, zainoId));
    await _deleteSubcollection(_tagsRef(uid, zainoId));
    await _zainiRef(uid).doc(zainoId).delete();
  }

  Future<Zaino?> getZainoByGoogleTaskListId(
    String uid,
    String googleTaskListId,
  ) async {
    final snap = await _zainiRef(
      uid,
    ).where('googleTaskListId', isEqualTo: googleTaskListId).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return Zaino.fromDoc(snap.docs.first);
  }

  // ── Items ────────────────────────────────────────────────────────────────────

  Stream<List<ZainoItem>> watchItems(String uid, String zainoId) {
    return _itemsRef(uid, zainoId)
        .orderBy('categoryName')
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => ZainoItem.fromDoc(d, zainoId)).toList());
  }

  Future<ZainoItem> createItem(
    String uid,
    String zainoId, {
    required String title,
    String? categoryName,
    List<String> tags = const [],
    String? googleTaskId,
    int? order,
    bool completed = false,
    String? id,
  }) async {
    final resolvedOrder =
        order ?? ((await _itemsRef(uid, zainoId).count().get()).count ?? 0);
    final now = DateTime.now();
    final item = ZainoItem(
      id: id ?? _uuid.v4(),
      zainoId: zainoId,
      title: title,
      completed: completed,
      order: resolvedOrder,
      googleTaskId: googleTaskId,
      categoryName: categoryName,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    await _itemsRef(uid, zainoId).doc(item.id).set(item.toMap());
    return item;
  }

  Future<void> updateItem(
    String uid,
    String zainoId,
    String itemId, {
    String? title,
    bool? completed,
    int? order,
    String? categoryName,
    List<String>? tags,
    String? googleTaskId,
    bool clearCategoryName = false,
  }) async {
    final data = <String, dynamic>{'updatedAt': Timestamp.now()};
    if (title != null) data['title'] = title;
    if (completed != null) data['completed'] = completed;
    if (order != null) data['order'] = order;
    if (clearCategoryName) {
      data['categoryName'] = FieldValue.delete();
    } else if (categoryName != null) {
      data['categoryName'] = categoryName;
    }
    if (tags != null) data['tags'] = tags;
    if (googleTaskId != null) data['googleTaskId'] = googleTaskId;
    await _itemsRef(uid, zainoId).doc(itemId).update(data);
  }

  Future<void> deleteItem(String uid, String zainoId, String itemId) async {
    await _itemsRef(uid, zainoId).doc(itemId).delete();
  }

  Future<void> resetAll(String uid, String zainoId) async {
    final snap = await _itemsRef(
      uid,
      zainoId,
    ).where('completed', isEqualTo: true).get();
    if (snap.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        'completed': false,
        'updatedAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  Future<List<ZainoItem>> getItemsByGoogleTaskIds(
    String uid,
    String zainoId,
    List<String> googleTaskIds,
  ) async {
    if (googleTaskIds.isEmpty) return [];
    final snap = await _itemsRef(
      uid,
      zainoId,
    ).where('googleTaskId', whereIn: googleTaskIds).get();
    return snap.docs.map((d) => ZainoItem.fromDoc(d, zainoId)).toList();
  }

  Future<List<ZainoItem>> getAllItems(String uid, String zainoId) async {
    final snap = await _itemsRef(uid, zainoId).get();
    return snap.docs.map((d) => ZainoItem.fromDoc(d, zainoId)).toList();
  }

  // ── Tags ─────────────────────────────────────────────────────────────────────

  Stream<List<ZainoTag>> watchTags(String uid, String zainoId) {
    return _tagsRef(uid, zainoId)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => ZainoTag.fromDoc(d, zainoId)).toList());
  }

  Future<ZainoTag> createTag(
    String uid,
    String zainoId, {
    required String name,
    int? order,
    String? id,
  }) async {
    final resolvedOrder =
        order ?? ((await _tagsRef(uid, zainoId).count().get()).count ?? 0);
    final tag = ZainoTag(
      id: id ?? _uuid.v4(),
      zainoId: zainoId,
      name: name,
      order: resolvedOrder,
      createdAt: DateTime.now(),
    );
    await _tagsRef(uid, zainoId).doc(tag.id).set(tag.toMap());
    return tag;
  }

  Future<void> updateTag(
    String uid,
    String zainoId,
    String tagId, {
    required String name,
  }) async {
    await _tagsRef(uid, zainoId).doc(tagId).update({'name': name});
  }

  Future<void> deleteTag(
    String uid,
    String zainoId,
    String tagId,
    String tagName,
  ) async {
    // Remove this tag from all items that reference it
    final items = await _itemsRef(
      uid,
      zainoId,
    ).where('tags', arrayContains: tagName).get();
    final batch = _firestore.batch();
    for (final doc in items.docs) {
      final current = List<String>.from(
        (doc.data()['tags'] as List<dynamic>?) ?? [],
      );
      current.remove(tagName);
      batch.update(doc.reference, {'tags': current});
    }
    batch.delete(_tagsRef(uid, zainoId).doc(tagId));
    await batch.commit();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<void> _deleteSubcollection(
    CollectionReference<Map<String, dynamic>> ref,
  ) async {
    const chunkSize = 500;
    QuerySnapshot<Map<String, dynamic>> snap;
    do {
      snap = await ref.limit(chunkSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snap.docs.length == chunkSize);
  }

  Future<void> deleteAllData(String uid) async {
    final zaini = await _zainiRef(uid).get();
    for (final doc in zaini.docs) {
      await deleteZaino(uid, doc.id);
    }
  }
}
