part of 'specializations_bloc.dart';

enum SpecializationsStatus { initial, loading, success, failure }

class SpecializationsState extends Equatable {
  final SpecializationsStatus status;

  /// The category these specializations belong to.
  final String? categoryId;
  final List<Specialization> specializations;

  /// Set when loading fails.
  final Failure? failure;

  const SpecializationsState({
    this.status = SpecializationsStatus.initial,
    this.categoryId,
    this.specializations = const [],
    this.failure,
  });

  bool get isLoading =>
      status == SpecializationsStatus.initial ||
      status == SpecializationsStatus.loading;

  @override
  List<Object?> get props => [status, categoryId, specializations, failure];
}
