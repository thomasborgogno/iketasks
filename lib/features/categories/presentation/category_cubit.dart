import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/category_repository.dart';
import '../domain/task_category.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(const CategoryState.initial());

  final CategoryRepository _repository;
  StreamSubscription<List<TaskCategory>>? _subscription;
  String? _uid;

  Future<void> bindUser(String uid) async {
    _uid = uid;
    emit(const CategoryState.loading());
    await _subscription?.cancel();
    _subscription = _repository
        .watchCategories(uid)
        .listen(
          (categories) => emit(CategoryState.loaded(categories)),
          onError: (error) => emit(CategoryState.error(error.toString())),
        );
  }

  Future<void> createCategory(String name, {String? emoji}) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.createCategory(uid, name, emoji: emoji);
  }

  Future<void> updateCategory(
    String categoryId, {
    required String name,
    String? emoji,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.updateCategory(uid, categoryId, name: name, emoji: emoji);
  }

  Future<void> deleteCategory(String categoryId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.deleteCategory(uid, categoryId);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
