import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/zaino_google_tasks_service.dart';
import '../data/zaino_repository.dart';
import '../domain/zaino.dart';
import 'zaino_state.dart';

/// List-level cubit: the zaini list itself (create/rename/delete a zaino,
/// per-zaino item counts, Google Tasks sync). See [ZainoDetailCubit] for the
/// per-zaino item/tag/category cubit.
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
        final counts = await _loadItemCounts(
          uid,
          zaini.map((z) => z.id).toList(),
        );
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
        var zaino = await _repo.getZainoByGoogleTaskListId(
          uid,
          listData.listId,
        );
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

  Future<void> createZaino({required String name, String? emoji}) async {
    final uid = _uid;
    if (uid == null) return;
    // Create in Google Tasks first
    final listId = await _googleTasksService.createList(name);
    await _repo.createZaino(
      uid,
      name: name,
      emoji: emoji,
      googleTaskListId: listId,
    );
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
