part of 'category_cubit.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState extends Equatable {
  const CategoryState._({
    required this.status,
    this.categories = const [],
    this.errorMessage,
  });

  const CategoryState.initial() : this._(status: CategoryStatus.initial);
  const CategoryState.loading() : this._(status: CategoryStatus.loading);
  const CategoryState.loaded(List<TaskCategory> categories)
      : this._(status: CategoryStatus.loaded, categories: categories);
  const CategoryState.error(String message)
      : this._(status: CategoryStatus.error, errorMessage: message);

  final CategoryStatus status;
  final List<TaskCategory> categories;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
