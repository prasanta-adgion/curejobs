import 'package:equatable/equatable.dart';

import 'verification_eligibility.dart';

/// One document attached to a verification request.
class VerificationDocument extends Equatable {
  final String id;
  final String documentTypeId;
  final String fileId;
  final VerificationDocumentStatus status;

  /// The reviewer's note on this document, e.g. why it was rejected.
  final String? reviewNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VerificationDocument({
    required this.id,
    required this.documentTypeId,
    required this.fileId,
    required this.status,
    this.reviewNote,
    this.createdAt,
    this.updatedAt,
  });

  /// Rejected (or needing changes / revoked): the user should delete it
  /// and upload a new document.
  bool get needsReplacing => switch (status) {
    VerificationDocumentStatus.rejected ||
    VerificationDocumentStatus.needsChanges ||
    VerificationDocumentStatus.revoked => true,
    VerificationDocumentStatus.notSubmitted ||
    VerificationDocumentStatus.pending ||
    VerificationDocumentStatus.approved => false,
  };

  @override
  List<Object?> get props => [
    id,
    documentTypeId,
    fileId,
    status,
    reviewNote,
    createdAt,
    updatedAt,
  ];
}

/// A verification request with its documents and review outcome, from
/// `GET verifications/{id}` and `POST verifications/{id}/submit`.
class VerificationRequestDetail extends Equatable {
  final String id;
  final VerificationRequestType? requestType;

  /// `NOT_SUBMITTED` until "Submit for review", then `PENDING`, etc.
  final VerificationDocumentStatus status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  /// Why the request was rejected; null unless it was.
  final String? rejectionReason;
  final List<VerificationDocument> documents;

  const VerificationRequestDetail({
    required this.id,
    required this.status,
    required this.documents,
    this.requestType,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  /// Not yet sent for review.
  bool get isDraft => status == VerificationDocumentStatus.notSubmitted;

  @override
  List<Object?> get props => [
    id,
    requestType,
    status,
    submittedAt,
    reviewedAt,
    rejectionReason,
    documents,
  ];
}
