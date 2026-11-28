import 'package:equatable/equatable.dart';

import 'verification_eligibility.dart';

/// From `GET verifications/me`: the user's own verification — document
/// status, badge, and the request already started, if any.
class CandidateVerification extends Equatable {
  final VerificationDocumentStatus documentStatus;
  final bool badgeActive;
  final bool requiresDocumentReview;
  final DateTime? documentVerifiedAt;
  final DateTime? documentRevokedAt;
  final String? badgeSource;
  final String? badgeKind;
  final String? badgeCollegeName;
  final DateTime? badgeStartsAt;
  final DateTime? badgeExpiresAt;
  final String? entitlementId;

  /// The started verification request; null when none has been started.
  final VerificationRequest? currentRequest;

  const CandidateVerification({
    required this.documentStatus,
    required this.badgeActive,
    required this.requiresDocumentReview,
    this.documentVerifiedAt,
    this.documentRevokedAt,
    this.badgeSource,
    this.badgeKind,
    this.badgeCollegeName,
    this.badgeStartsAt,
    this.badgeExpiresAt,
    this.entitlementId,
    this.currentRequest,
  });

  bool get hasStarted => currentRequest != null;

  @override
  List<Object?> get props => [
    documentStatus,
    badgeActive,
    requiresDocumentReview,
    documentVerifiedAt,
    documentRevokedAt,
    badgeSource,
    badgeKind,
    badgeCollegeName,
    badgeStartsAt,
    badgeExpiresAt,
    entitlementId,
    currentRequest,
  ];
}
