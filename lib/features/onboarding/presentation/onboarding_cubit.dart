import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/onboarding_repository.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository) : super(const OnboardingState.loading());

  final OnboardingRepository _repository;

  Future<void> checkOnboardingStatus() async {
    try {
      emit(const OnboardingState.loading());
      final hasCompleted = await _repository.hasCompletedOnboarding();
      if (hasCompleted) {
        emit(const OnboardingState.completed());
      } else {
        emit(const OnboardingState.required());
      }
    } catch (e) {
      emit(OnboardingState.error(e.toString()));
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _repository.markOnboardingComplete();
      emit(const OnboardingState.completed());
    } catch (e) {
      emit(OnboardingState.error(e.toString()));
    }
  }

  Future<void> resetOnboarding() async {
    try {
      await _repository.resetOnboarding();
      emit(const OnboardingState.required());
    } catch (e) {
      emit(OnboardingState.error(e.toString()));
    }
  }
}
