import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/zaino_google_tasks_service.dart';
import '../data/zaino_repository.dart';
import '../domain/zaino.dart';
import '../domain/zaino_item.dart';
import '../domain/zaino_tag.dart';
import 'zaino_state.dart';

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
      emit(state.copyWith(isSyncing: false));
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
    await _repo.resetAll(uid, _zaino.id);
    if (_zaino.googleTaskListId != null) {
      final completedItems = state.items
          .where((i) => i.completed && i.googleTaskId != null)
          .map((i) => i.googleTaskId!)
          .toList();
      if (completedItems.isNotEmpty) {
        await _googleTasksService.resetAllTasks(
          _zaino.googleTaskListId!,
          completedItems,
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
    );
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

  Future<void> deleteItem(ZainoItem item) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteItem(uid, _zaino.id, item.id);
    if (item.googleTaskId != null && _zaino.googleTaskListId != null) {
      await _googleTasksService.deleteTask(
        _zaino.googleTaskListId!,
        item.googleTaskId!,
      );
    }
  }

  Future<void> createTag(String name) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.createTag(uid, _zaino.id, name: name);
  }

  Future<void> updateTag(ZainoTag tag, String newName) async {
    final uid = _uid;
    if (uid == null) return;
    // Update tag name on all items referencing the old name
    final itemsWithTag = state.items
        .where((i) => i.tags.contains(tag.name))
        .toList();
    for (final item in itemsWithTag) {
      final newTags = [...item.tags];
      final idx = newTags.indexOf(tag.name);
      if (idx >= 0) newTags[idx] = newName;
      await _repo.updateItem(uid, _zaino.id, item.id, tags: newTags);
    }
    await _repo.updateTag(uid, _zaino.id, tag.id, name: newName);
  }

  Future<void> deleteTag(ZainoTag tag) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteTag(uid, _zaino.id, tag.id, tag.name);
  }

  @override
  Future<void> close() {
    _itemsSub?.cancel();
    _tagsSub?.cancel();
    return super.close();
  }
}
