part of 'resume_bloc.dart';

enum ResumeStatus { initial, loading, success, failure }

class ResumeState extends Equatable {
  final ResumeStatus status;
  final List<Resume> items;

  /// Set when loading fails.
  final Failure? failure;

  /// Id of the resume whose download URL is being fetched.
  final String? downloadingId;

  /// Set for one state when a download URL arrives.
  final String? downloadUrl;

  /// Set for one state when fetching the download URL fails.
  final Failure? actionFailure;

  /// Id of the resume being made the default.
  final String? settingDefaultId;

  /// True for one state after a CV became the default.
  final bool defaultChanged;

  /// Set for one state when making a CV the default fails.
  final Failure? defaultFailure;

  /// Id of the resume being deleted.
  final String? deletingId;

  /// True for one state after a CV was deleted.
  final bool deleted;

  /// Set for one state when deleting a CV fails.
  final Failure? deleteFailure;

  const ResumeState({
    this.status = ResumeStatus.initial,
    this.items = const [],
    this.failure,
    this.downloadingId,
    this.downloadUrl,
    this.actionFailure,
    this.settingDefaultId,
    this.defaultChanged = false,
    this.defaultFailure,
    this.deletingId,
    this.deleted = false,
    this.deleteFailure,
  });

  bool get isLoading =>
      status == ResumeStatus.initial || status == ResumeStatus.loading;

  /// Whether [id] has a download, set-default or delete request running.
  bool isBusy(String id) =>
      downloadingId == id || settingDefaultId == id || deletingId == id;

  /// Default resume first, then most recently updated.
  List<Resume> get sorted {
    final list = [...items];
    list.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      final at = a.updatedAt ?? a.createdAt;
      final bt = b.updatedAt ?? b.createdAt;
      if (at == null || bt == null) return 0;
      return bt.compareTo(at);
    });
    return list;
  }

  /// [failure] and all the one-off action fields reset unless passed again.
  ResumeState copyWith({
    ResumeStatus? status,
    List<Resume>? items,
    Failure? failure,
    String? downloadingId,
    String? downloadUrl,
    Failure? actionFailure,
    String? settingDefaultId,
    bool defaultChanged = false,
    Failure? defaultFailure,
    String? deletingId,
    bool deleted = false,
    Failure? deleteFailure,
  }) {
    return ResumeState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
      downloadingId: downloadingId,
      downloadUrl: downloadUrl,
      actionFailure: actionFailure,
      settingDefaultId: settingDefaultId,
      defaultChanged: defaultChanged,
      defaultFailure: defaultFailure,
      deletingId: deletingId,
      deleted: deleted,
      deleteFailure: deleteFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    failure,
    downloadingId,
    downloadUrl,
    actionFailure,
    settingDefaultId,
    defaultChanged,
    defaultFailure,
    deletingId,
    deleted,
    deleteFailure,
  ];
}
