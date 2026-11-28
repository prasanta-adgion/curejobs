part of 'verification_bloc.dart';

enum VerificationStatus { initial, loading, ready, failure }

/// Everything the verification page shows. Raw API data is stored as is;
/// what the UI needs (step, request id, …) is derived in the getters below,
/// so there is one source of truth.
final class VerificationState extends Equatable {
  const VerificationState({
    this.status = VerificationStatus.initial,
    this.failure,
    this.eligibility,
    this.myVerification,
    this.request,
    this.createdRequestId,
    this.typesLoad = const TypesLoad.idle(),
    this.documentTypes = const [],
    this.fileNames = const {},
    this.deletingIds = const {},
    this.submitting = false,
    this.message,
  });

  final VerificationStatus status;

  /// Why the last load failed; set only with [VerificationStatus.failure].
  final Failure? failure;

  /// From `verifications/eligibility`; null until first loaded.
  final VerificationEligibility? eligibility;

  /// From `verifications/me`; null until loaded or if that call failed.
  final CandidateVerification? myVerification;

  /// `GET verifications/{id}`: documents, statuses, rejection reason.
  final VerificationRequestDetail? request;

  /// Id of the request "Start verification" created, if any.
  final String? createdRequestId;

  final TypesLoad typesLoad;
  final List<VerificationDocumentType> documentTypes;

  /// File names of documents uploaded in this session, by `fileId` (the
  /// API only returns ids).
  final Map<String, String> fileNames;

  /// Ids of documents being deleted, to show a spinner on each.
  final Set<String> deletingIds;

  /// "Submit for review" is running.
  final bool submitting;

  /// One-off error for a snackbar. Cleared by the next state change.
  final String? message;

  // ── Derived ───────────────────────────────────────────────────────────────

  /// A request was started before, so the start card is skipped.
  bool get alreadyStarted => myVerification?.hasStarted ?? false;

  /// The request documents are attached to: the one already started, else
  /// the one "Start verification" created.
  String? get requestId =>
      myVerification?.currentRequest?.id ??
      createdRequestId ??
      eligibility?.currentRequest?.id;

  /// Documents attached so far, incl. rejected ones.
  List<VerificationDocument> get documents => request?.documents ?? const [];

  /// Only one active (not rejected) document is allowed. While one is
  /// attached the upload form hides and "Submit for review" turns on.
  bool get hasActiveDocument => documents.any((d) => !d.needsReplacing);

  /// The step to show; null until eligibility is loaded.
  ///
  /// Purchase needed → plan; badge live → badge; otherwise the document
  /// status decides: sent or approved → review; anything else → documents.
  VerificationStep? get step {
    final e = eligibility;
    if (e == null) return null;
    if (e.requiresPurchase) return VerificationStep.plan;
    if (e.badgeActive) return VerificationStep.badge;
    return switch (_documentStatus(e)) {
      VerificationDocumentStatus.pending ||
      VerificationDocumentStatus.approved => VerificationStep.review,
      VerificationDocumentStatus.notSubmitted ||
      VerificationDocumentStatus.needsChanges ||
      VerificationDocumentStatus.rejected ||
      VerificationDocumentStatus.revoked => VerificationStep.documents,
    };
  }

  /// From the request detail when loaded (it reflects the admin's review per
  /// document; eligibility's status can lag behind), else from eligibility.
  /// A rejected document wins, so the user is sent back to upload again.
  VerificationDocumentStatus _documentStatus(VerificationEligibility e) {
    final r = request;
    if (r == null) return e.documentStatus;
    final rejected = r.documents.where((d) => d.needsReplacing).firstOrNull;
    return rejected?.status ?? r.status;
  }

  /// [failure] and [message] are one-off: they reset unless passed again.
  VerificationState copyWith({
    VerificationStatus? status,
    Failure? failure,
    VerificationEligibility? eligibility,
    CandidateVerification? Function()? myVerification,
    VerificationRequestDetail? request,
    String? createdRequestId,
    TypesLoad? typesLoad,
    List<VerificationDocumentType>? documentTypes,
    Map<String, String>? fileNames,
    Set<String>? deletingIds,
    bool? submitting,
    String? message,
  }) {
    return VerificationState(
      status: status ?? this.status,
      failure: failure,
      eligibility: eligibility ?? this.eligibility,
      myVerification: myVerification != null
          ? myVerification()
          : this.myVerification,
      request: request ?? this.request,
      createdRequestId: createdRequestId ?? this.createdRequestId,
      typesLoad: typesLoad ?? this.typesLoad,
      documentTypes: documentTypes ?? this.documentTypes,
      fileNames: fileNames ?? this.fileNames,
      deletingIds: deletingIds ?? this.deletingIds,
      submitting: submitting ?? this.submitting,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    failure,
    eligibility,
    myVerification,
    request,
    createdRequestId,
    typesLoad,
    documentTypes,
    fileNames,
    deletingIds,
    submitting,
    message,
  ];
}
