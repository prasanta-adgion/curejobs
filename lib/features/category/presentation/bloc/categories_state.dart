part of 'categories_bloc.dart';

enum CategoriesStatus { initial, loading, success, failure }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<Category> categories;

  /// Set when loading fails.
  final Failure? failure;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.failure,
  });

  bool get isLoading =>
      status == CategoriesStatus.initial || status == CategoriesStatus.loading;

  @override
  List<Object?> get props => [status, categories, failure];
}
