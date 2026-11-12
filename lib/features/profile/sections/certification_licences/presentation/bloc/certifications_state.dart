part of 'certifications_bloc.dart';

enum CertificationsStatus { initial, loading, success, failure }

class CertificationsState extends Equatable {
  final CertificationsStatus status;
  final List<Certification> items;

  /// Set when loading fails.
  final Failure? failure;

  /// Ids of certificates whose delete request is still running.
  final Set<String> deletingIds;

  /// Set for one state right after a delete from the list succeeds.
  final bool deleted;

  /// Set for one state when a delete from the list fails.
  final Failure? actionFailure;

  const CertificationsState({
    this.status = CertificationsStatus.initial,
    this.items = const [],
    this.failure,
    this.deletingIds = const {},
    this.deleted = false,
    this.actionFailure,
  });

  bool get isLoading =>
      status == CertificationsStatus.initial ||
      status == CertificationsStatus.loading;

  bool isDeleting(Certification c) => deletingIds.contains(c.id);

  /// Expiring or expired ones, for the banner.
  List<Certification> get needingRenewal => [
    for (final c in items)
      if (c.needsRenewal) c,
  ];

  /// [failure], [deleted] and [actionFailure] are one-off values and reset
  /// unless passed again.
  CertificationsState copyWith({
    CertificationsStatus? status,
    List<Certification>? items,
    Failure? failure,
    Set<String>? deletingIds,
    bool deleted = false,
    Failure? actionFailure,
  }) {
    return CertificationsState(
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
