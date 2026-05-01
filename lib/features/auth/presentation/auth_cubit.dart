import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/categories/data/category_repository.dart';
import '../../../features/tasks/data/task_repository.dart';
import '../data/auth_repository.dart';
export '../data/auth_repository.dart' show UpgradeResult;

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepository, {
    required TaskRepository taskRepository,
    required CategoryRepository categoryRepository,
  }) : _taskRepository = taskRepository,
       _categoryRepository = categoryRepository,
       super(const AuthState.unknown()) {
    _subscription = _authRepository.authStateChanges().listen((user) {
      if (user == null) {
        emit(const AuthState.unauthenticated());
      } else {
        emit(AuthState.authenticated(user));
      }
    });
  }

  final AuthRepository _authRepository;
  final TaskRepository _taskRepository;
  final CategoryRepository _categoryRepository;
  StreamSubscription<User?>? _subscription;

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    try {
      final credential = await _authRepository.signInWithGoogle();
      emit(AuthState.authenticated(credential.user!));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> signInAnonymously() async {
    emit(const AuthState.loading());
    try {
      final credential = await _authRepository.signInAnonymously();
      emit(AuthState.authenticated(credential.user!));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  /// Returns [UpgradeResult.success] or [UpgradeResult.conflict].
  /// On conflict the user is already signed into their Google account.
  Future<UpgradeResult> upgradeToGoogle() async {
    emit(const AuthState.loading());
    try {
      final result = await _authRepository.upgradeToGoogle();
      // Auth stream will fire and re-emit authenticated state automatically.
      return result;
    } catch (e) {
      emit(AuthState.error(e.toString()));
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) return;
    emit(const AuthState.loading());
    try {
      await _taskRepository.deleteAllData(uid);
      await _categoryRepository.deleteAllData(uid);
      await _authRepository.deleteAccount();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
