part of 'education_bloc.dart';

enum EducationStatus { initial, loading, success, failure }

class EducationState extends Equatable {
  final EducationStatus status;
  final List<Education> items;

  /// Set when loading fails.
  final Failure? failure;

  const EducationState({
    this.status = EducationStatus.initial,
    this.items = const [],
    this.failure,
  });

  bool get isLoading =>
      status == EducationStatus.initial || status == EducationStatus.loading;

  @override
  List<Object?> get props => [status, items, failure];
}
