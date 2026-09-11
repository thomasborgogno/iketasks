import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../data/zaino_google_tasks_service.dart';
import '../data/zaino_repository.dart';
import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import '../domain/zaino_tag.dart';
import 'zaino_state.dart';

const _uuid = Uuid();

class ZainoCubit extends Cubit<ZainoState> {
  ZainoCubit(this._repo, this._googleTasksService) : super(const ZainoState());

  final ZainoRepository _repo;
  final ZainoGoogleTasksService _googleTasksService;

  String? _uid;
  StreamSubscription<List<Zaino>>? _zainiSub;

  void bindUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _zainiSub?.cancel();
    emit(state.copyWith(status: ZainoStatus.loading));
    _zainiSub = _repo.watchZaini(uid).listen(
      (zaini) async {
        emit(state.copyWith(status: ZainoStatus.ready, zaini: zaini));
        final counts = await _loadItemCounts(uid, zaini.map((z) => z.id).toList());
        if (!isClosed) emit(state.copyWith(itemCounts: counts));
      },
      onError: (e) => emit(
        state.copyWith(status: ZainoStatus.error, errorMessage: e.toString()),
      ),
    );
    syncFromGoogleTasks();
  }

  Future<void> refreshItemCounts() async {
    final uid = _uid;
    if (uid == null) return;
    final counts = await _loadItemCounts(
      uid,
      state.zaini.map((z) => z.id).toList(),
    );
    if (!isClosed) emit(state.copyWith(itemCounts: counts));
  }

  void unbind() {
    _uid = null;
    _zainiSub?.cancel();
    emit(const ZainoState());
  }

  Future<Map<String, int>> _loadItemCounts(
    String uid,
    List<String> zainoIds,
  ) async {
    final counts = <String, int>{};
    for (final id in zainoIds) {
      try {
        final items = await _repo.getAllItems(uid, id);
        counts[id] = items.length;
      } catch (_) {
        counts[id] = 0;
      }
    }
    return counts;
  }

  Future<void> syncFromGoogleTasks() async {
    final uid = _uid;
    if (uid == null) return;
    emit(state.copyWith(isSyncing: true));
    try {
      final lists = await _googleTasksService.fetchZainoLists();
      for (final listData in lists) {
        var zaino = await _repo.getZainoByGoogleTaskListId(uid, listData.listId);
        if (zaino == null) {
          zaino = await _repo.createZaino(
            uid,
            name: listData.name,
            googleTaskListId: listData.listId,
          );
        }
        // Sync tasks
        final existingItems = await _repo.getAllItems(uid, zaino.id);
        final existingByGoogleId = {
          for (final item in existingItems)
            if (item.googleTaskId != null) item.googleTaskId!: item,
        };
        for (final taskData in listData.tasks) {
          final existing = existingByGoogleId[taskData.id];
          if (existing == null) {
            await _repo.createItem(
              uid,
              zaino.id,
              title: taskData.title,
              googleTaskId: taskData.id,
              completed: taskData.completed,
            );
          } else if (existing.completed != taskData.completed) {
            await _repo.updateItem(
              uid,
              zaino.id,
              existing.id,
              completed: taskData.completed,
            );
          }
        }
      }
    } finally {
      if (!isClosed) emit(state.copyWith(isSyncing: false));
    }
  }

  Future<void> createZaino({
    required String name,
    String? emoji,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    // Create in Google Tasks first
    final listId = await _googleTasksService.createList(name);
    await _repo.createZaino(uid, name: name, emoji: emoji, googleTaskListId: listId);
  }

  Future<void> updateZaino(
    Zaino zaino, {
    String? name,
    String? emoji,
    bool clearEmoji = false,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.updateZaino(
      uid,
      zaino.id,
      name: name,
      emoji: emoji,
      clearEmoji: clearEmoji,
    );
    // Rename in Google Tasks
    if (name != null && zaino.googleTaskListId != null) {
      await _googleTasksService.renameList(zaino.googleTaskListId!, name);
    }
  }

  Future<void> deleteZaino(Zaino zaino) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteZaino(uid, zaino.id);
    if (zaino.googleTaskListId != null) {
      await _googleTasksService.deleteList(zaino.googleTaskListId!);
    }
  }

  @override
  Future<void> close() {
    _zainiSub?.cancel();
    return super.close();
  }
}

// ── Per-zaino detail cubit ───────────────────────────────────────────────────

class ZainoDetailCubit extends Cubit<ZainoDetailState> {
  ZainoDetailCubit(this._repo, this._googleTasksService, this._zaino)
      : super(const ZainoDetailState());

  final ZainoRepository _repo;
  final ZainoGoogleTasksService _googleTasksService;
  final Zaino _zaino;

  String? _uid;
  StreamSubscription<List<ZainoItem>>? _itemsSub;
  StreamSubscription<List<ZainoTag>>? _tagsSub;

  void bindUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    _init();
  }

  void _init() {
    final uid = _uid;
    if (uid == null) return;
    emit(state.copyWith(status: ZainoStatus.loading));
    _itemsSub?.cancel();
    _tagsSub?.cancel();
    _itemsSub = _repo.watchItems(uid, _zaino.id).listen(
      (items) => emit(state.copyWith(status: ZainoStatus.ready, items: items)),
      onError: (e) => emit(
        state.copyWith(
          status: ZainoStatus.error,
          errorMessage: e.toString(),
        ),
      ),
    );
    _tagsSub = _repo.watchTags(uid, _zaino.id).listen(
      (tags) => emit(state.copyWith(tags: tags)),
    );
  }

  void setTagFilter(List<String> tags) {
    emit(state.copyWith(activeTagFilter: tags));
  }

  Future<void> toggleItem(ZainoItem item) async {
    final uid = _uid;
    if (uid == null) return;
    final newCompleted = !item.completed;
    // Optimistic update: show change immediately without waiting for Firestore
    emit(state.copyWith(
      items: [
        for (final i in state.items)
          if (i.id == item.id) i.copyWith(completed: newCompleted) else i,
      ],
    ));
    await _repo.updateItem(uid, _zaino.id, item.id, completed: newCompleted);
    if (item.googleTaskId != null && _zaino.googleTaskListId != null) {
      await _googleTasksService.setTaskCompleted(
        _zaino.googleTaskListId!,
        item.googleTaskId!,
        newCompleted,
      );
    }
  }

  Future<void> resetAll() async {
    final uid = _uid;
    if (uid == null) return;
    final completedItems = state.items.where((i) => i.completed).toList();
    if (completedItems.isEmpty) return;
    // Optimistic update: uncheck everything immediately.
    emit(state.copyWith(
      items: [
        for (final i in state.items)
          if (i.completed) i.copyWith(completed: false) else i,
      ],
    ));
    await _repo.resetAll(uid, _zaino.id);
    if (_zaino.googleTaskListId != null) {
      final googleIds = completedItems
          .where((i) => i.googleTaskId != null)
          .map((i) => i.googleTaskId!)
          .toList();
      if (googleIds.isNotEmpty) {
        await _googleTasksService.resetAllTasks(
          _zaino.googleTaskListId!,
          googleIds,
        );
      }
    }
  }

  Future<void> createItem({
    required String title,
    String? categoryName,
    List<String> tags = const [],
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final now = DateTime.now();
    final item = ZainoItem(
      id: _uuid.v4(),
      zainoId: _zaino.id,
      title: title,
      completed: false,
      order: state.items.length,
      categoryName: categoryName,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    // Optimistic add: show the new item immediately.
    emit(state.copyWith(items: [...state.items, item]));

    String? googleTaskId;
    if (_zaino.googleTaskListId != null) {
      googleTaskId = await _googleTasksService.createTask(
        _zaino.googleTaskListId!,
        title,
      );
    }
    await _repo.createItem(
      uid,
      _zaino.id,
      title: title,
      categoryName: categoryName,
      tags: tags,
      googleTaskId: googleTaskId,
      order: item.order,
      id: item.id,
    );
    if (googleTaskId != null && !isClosed) {
      emit(state.copyWith(
        items: [
          for (final i in state.items)
            if (i.id == item.id) i.copyWith(googleTaskId: googleTaskId) else i,
        ],
      ));
    }
  }

  Future<void> updateItem(
    ZainoItem item, {
    String? title,
    String? categoryName,
    List<String>? tags,
    bool clearCategoryName = false,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final updated = item.copyWith(
      title: title,
      categoryName: categoryName,
      tags: tags,
      clearCategoryName: clearCategoryName,
    );
    // Optimistic update: reflect edits immediately.
    emit(state.copyWith(
      items: [
        for (final i in state.items) if (i.id == item.id) updated else i,
      ],
    ));
    await _repo.updateItem(
      uid,
      _zaino.id,
      item.id,
      title: title,
      categoryName: categoryName,
      tags: tags,
      clearCategoryName: clearCategoryName,
    );
  }

  /// Renames [oldName] to [newName] on every item currently under it.
  /// Categories aren't a persisted entity — they're just the distinct
  /// `categoryName` values across items — so this is a bulk item update.
  Future<void> renameCategory(String oldName, String newName) async {
    final uid = _uid;
    if (uid == null || newName.isEmpty || newName == oldName) return;
    final affected = state.items.where((i) => i.categoryName == oldName).toList();
    if (affected.isEmpty) return;
    // Optimistic update.
    emit(state.copyWith(
      items: [
        for (final i in state.items)
          if (i.categoryName == oldName) i.copyWith(categoryName: newName) else i,
      ],
    ));
    for (final item in affected) {
      await _repo.updateItem(uid, _zaino.id, item.id, categoryName: newName);
    }
  }

  /// Clears [name] from every item currently under it, leaving them
  /// uncategorized. See [renameCategory].
  Future<void> deleteCategory(String name) async {
    final uid = _uid;
    if (uid == null) return;
    final affected = state.items.where((i) => i.categoryName == name).toList();
    if (affected.isEmpty) return;
    // Optimistic update.
    emit(state.copyWith(
      items: [
        for (final i in state.items)
          if (i.categoryName == name) i.copyWith(clearCategoryName: true) else i,
      ],
    ));
    for (final item in affected) {
      await _repo.updateItem(
        uid,
        _zaino.id,
        item.id,
        clearCategoryName: true,
      );
    }
  }

  Future<void> deleteItem(ZainoItem item) async {
    final uid = _uid;
    if (uid == null) return;
    // Optimistic remove.
    emit(state.copyWith(
      items: state.items.where((i) => i.id != item.id).toList(),
    ));
    await _repo.deleteItem(uid, _zaino.id, item.id);
    if (item.googleTaskId != null && _zaino.googleTaskListId != null) {
      await _googleTasksService.deleteTask(
        _zaino.googleTaskListId!,
        item.googleTaskId!,
      );
    }
  }

  /// Adds [tagNames] to every item in [itemIds], merging with existing tags.
  Future<void> bulkAddTags(List<String> itemIds, List<String> tagNames) async {
    final uid = _uid;
    if (uid == null || tagNames.isEmpty || itemIds.isEmpty) return;
    final idSet = itemIds.toSet();
    final newItems = <ZainoItem>[];
    for (final i in state.items) {
      if (idSet.contains(i.id)) {
        final merged = {...i.tags, ...tagNames}.toList();
        newItems.add(i.copyWith(tags: merged));
      } else {
        newItems.add(i);
      }
    }
    emit(state.copyWith(items: newItems));
    for (final item in newItems) {
      if (idSet.contains(item.id)) {
        await _repo.updateItem(uid, _zaino.id, item.id, tags: item.tags);
      }
    }
  }

  /// Sets (or clears, when [categoryName] is null) the category on every
  /// item in [itemIds] at once — unlike tags, an item has a single category,
  /// so this replaces rather than merges.
  Future<void> bulkSetCategory(
    List<String> itemIds,
    String? categoryName,
  ) async {
    final uid = _uid;
    if (uid == null || itemIds.isEmpty) return;
    final idSet = itemIds.toSet();
    final newItems = <ZainoItem>[
      for (final i in state.items)
        if (idSet.contains(i.id))
          i.copyWith(categoryName: categoryName, clearCategoryName: categoryName == null)
        else
          i,
    ];
    emit(state.copyWith(items: newItems));
    for (final item in newItems) {
      if (idSet.contains(item.id)) {
        await _repo.updateItem(
          uid,
          _zaino.id,
          item.id,
          categoryName: categoryName,
          clearCategoryName: categoryName == null,
        );
      }
    }
  }

  Future<void> createTag(String name) async {
    final uid = _uid;
    if (uid == null) return;
    final tag = ZainoTag(
      id: _uuid.v4(),
      zainoId: _zaino.id,
      name: name,
      order: state.tags.length,
      createdAt: DateTime.now(),
    );
    // Optimistic add.
    emit(state.copyWith(tags: [...state.tags, tag]));
    await _repo.createTag(uid, _zaino.id, name: name, order: tag.order, id: tag.id);
  }

  Future<void> updateTag(ZainoTag tag, String newName) async {
    final uid = _uid;
    if (uid == null) return;
    // Update tag name on all items referencing the old name.
    final itemsWithTag = state.items
        .where((i) => i.tags.contains(tag.name))
        .toList();
    final renamedById = <String, List<String>>{};
    for (final item in itemsWithTag) {
      final newTags = [...item.tags];
      final idx = newTags.indexOf(tag.name);
      if (idx >= 0) newTags[idx] = newName;
      renamedById[item.id] = newTags;
    }
    // Optimistic update: rename the tag, its item references, and the active filter.
    emit(state.copyWith(
      tags: [
        for (final t in state.tags) if (t.id == tag.id) t.copyWith(name: newName) else t,
      ],
      items: [
        for (final i in state.items)
          if (renamedById.containsKey(i.id)) i.copyWith(tags: renamedById[i.id]) else i,
      ],
      activeTagFilter: [
        for (final f in state.activeTagFilter) f == tag.name ? newName : f,
      ],
    ));
    for (final entry in renamedById.entries) {
      await _repo.updateItem(uid, _zaino.id, entry.key, tags: entry.value);
    }
    await _repo.updateTag(uid, _zaino.id, tag.id, name: newName);
  }

  Future<void> deleteTag(ZainoTag tag) async {
    final uid = _uid;
    if (uid == null) return;
    // Optimistic remove: drop the tag and strip it from any item referencing it.
    emit(state.copyWith(
      tags: state.tags.where((t) => t.id != tag.id).toList(),
      items: [
        for (final i in state.items)
          if (i.tags.contains(tag.name))
            i.copyWith(tags: i.tags.where((t) => t != tag.name).toList())
          else
            i,
      ],
      activeTagFilter: state.activeTagFilter.where((f) => f != tag.name).toList(),
    ));
    await _repo.deleteTag(uid, _zaino.id, tag.id, tag.name);
  }

  @override
  Future<void> close() {
    _itemsSub?.cancel();
    _tagsSub?.cancel();
    return super.close();
  }
}
