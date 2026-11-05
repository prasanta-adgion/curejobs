part of 'specializations_bloc.dart';

sealed class SpecializationsEvent extends Equatable {
  const SpecializationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load a category's specializations, or reload them (retry).
final class SpecializationsRequested extends SpecializationsEvent {
  final String categoryId;

  const SpecializationsRequested(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
