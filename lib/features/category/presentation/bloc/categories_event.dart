part of 'categories_bloc.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

/// Load the categories, or reload them (retry).
final class CategoriesRequested extends CategoriesEvent {
  const CategoriesRequested();
}
