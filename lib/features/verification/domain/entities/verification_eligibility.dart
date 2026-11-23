import 'package:equatable/equatable.dart';

/// Where the user's documents are, from `documentStatus`.
enum VerificationDocumentStatus { notSubmitted, pending, approved, rejected }

/// From `GET verifications/eligibility`.
class VerificationEligibility extends Equatable {
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

  final bool eligible;
  final VerificationDocumentStatus documentStatus;
  final bool badgeActive;
  final bool requiresPurchase;
  final bool requiresDocumentReview;

  /// e.g. `PENDING_REVIEW`.
  final String? action;
  final String? badgeKind;
  final String? badgeCollegeName;

  /// `currentVerificationRequest`, when one exists.
  final VerificationRequest? currentRequest;

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
  const VerificationRequest({
    required this.id,
    required this.status,
    this.submittedAt,
  });

  final String id;

  /// e.g. `PENDING`.
  final String status;
  final DateTime? submittedAt;

  @override
  List<Object?> get props => [id, status, submittedAt];
}
