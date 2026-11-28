import 'package:equatable/equatable.dart';

/// `action` of the eligibility API: what the user should do next.
enum VerificationEligibilityAction {
  /// `FIRST_TIME_VERIFICATION`: never verified; upload documents.
  firstTimeVerification,

  /// `REVERIFICATION`: verify again (e.g. after rejection or revocation).
  reverification,

  /// `PENDING_REVIEW`: documents sent; waiting for the admin.
  pendingReview,

  /// `RENEW`: verified before; renew the badge.
  renew,
}

/// `documentStatus` of both the eligibility and `verifications/me` APIs:
/// where the user's documents are.
enum VerificationDocumentStatus {
  notSubmitted,
  pending,
  needsChanges,
  approved,
  rejected,
  revoked,
}

/// `requestType` of a verification request.
enum VerificationRequestType { firstTime, reverification }

/// From `GET verifications/eligibility`.
class VerificationEligibility extends Equatable {
  final bool eligible;
  final VerificationDocumentStatus documentStatus;
  final bool badgeActive;
  final bool requiresPurchase;
  final bool requiresDocumentReview;

  /// What the user should do next; null when the API sends none.
  final VerificationEligibilityAction? action;
  final String? badgeKind;
  final String? badgeCollegeName;

  /// `currentVerificationRequest`, when one exists.
  final VerificationRequest? currentRequest;

  const VerificationEligibility({
    required this.eligible,
    required this.documentStatus,
    required this.badgeActive,
    required this.requiresPurchase,
    required this.requiresDocumentReview,
    this.action,
    this.badgeKind,
    this.badgeCollegeName,
    this.currentRequest,
  });

  @override
  List<Object?> get props => [
    eligible,
    documentStatus,
    badgeActive,
    requiresPurchase,
    requiresDocumentReview,
    action,
    badgeKind,
    badgeCollegeName,
    currentRequest,
  ];
}

/// The latest verification request the user sent.
class VerificationRequest extends Equatable {
  final String id;

  /// e.g. `NOT_SUBMITTED`, `PENDING`.
  final String status;

  /// Not sent by the eligibility API.
  final VerificationRequestType? requestType;
  final DateTime? submittedAt;

  const VerificationRequest({
    required this.id,
    required this.status,
    this.requestType,
    this.submittedAt,
  });

  @override
  List<Object?> get props => [id, status, requestType, submittedAt];
}
