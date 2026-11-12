part of 'education_bloc.dart';

enum EducationStatus { initial, loading, success, failure }

class EducationState extends Equatable {
  final EducationStatus status;
  final List<Education> items;

  /// Set when loading fails.
  final Failure? failure;

  /// Ids of entries whose delete request is still running.
  final Set<String> deletingIds;

  /// Set for one state right after a delete from the list succeeds.
  final bool deleted;

  /// Set for one state when a delete from the list fails.
  final Failure? actionFailure;

  const EducationState({
    this.status = EducationStatus.initial,
    this.items = const [],
    this.failure,
    this.deletingIds = const {},
    this.deleted = false,
    this.actionFailure,
  });

  bool get isLoading =>
      status == EducationStatus.initial || status == EducationStatus.loading;

  bool isDeleting(Education education) => deletingIds.contains(education.id);

  /// [failure], [deleted] and [actionFailure] are one-off values and reset
  /// unless passed again.
  EducationState copyWith({
    EducationStatus? status,
    List<Education>? items,
    Failure? failure,
    Set<String>? deletingIds,
    bool deleted = false,
    Failure? actionFailure,
  }) {
    return EducationState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
      deletingIds: deletingIds ?? this.deletingIds,
      deleted: deleted,
      actionFailure: actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    failure,
    deletingIds,
    deleted,
    actionFailure,
  ];
}
