part of 'onboarding_cubit.dart';

enum OnboardingStatus { loading, required, completed, error }

class OnboardingState extends Equatable {
  const OnboardingState._({
    required this.status,
    this.errorMessage,
  });

  const OnboardingState.loading()
      : this._(status: OnboardingStatus.loading);

  const OnboardingState.required()
      : this._(status: OnboardingStatus.required);

  const OnboardingState.completed()
      : this._(status: OnboardingStatus.completed);

  const OnboardingState.error(String message)
      : this._(status: OnboardingStatus.error, errorMessage: message);

  final OnboardingStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
