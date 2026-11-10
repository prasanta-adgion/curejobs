part of 'experience_bloc.dart';

enum ExperienceStatus { initial, loading, success, failure }

class ExperienceState extends Equatable {
  final ExperienceStatus status;
  final List<Experience> items;

  /// Set when loading fails.
  final Failure? failure;

  /// Set when deleting from the list fails; the item is restored.
  final Failure? deleteFailure;

  const ExperienceState({
    this.status = ExperienceStatus.initial,
    this.items = const [],
    this.failure,
    this.deleteFailure,
  });

  bool get isLoading =>
      status == ExperienceStatus.initial || status == ExperienceStatus.loading;

  static const _keep = Object();

  ExperienceState copyWith({
    ExperienceStatus? status,
    List<Experience>? items,
    Object? failure = _keep,
    Object? deleteFailure = _keep,
  }) {
    return ExperienceState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: identical(failure, _keep) ? this.failure : failure as Failure?,
      deleteFailure: identical(deleteFailure, _keep)
          ? null
          : deleteFailure as Failure?,
    );
  }

  @override
  List<Object?> get props => [status, items, failure, deleteFailure];
}
