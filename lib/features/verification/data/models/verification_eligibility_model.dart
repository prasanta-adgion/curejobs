import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/verification_eligibility.dart';
import 'verification_request_model.dart';

class VerificationEligibilityModel extends VerificationEligibility {
  const VerificationEligibilityModel({
    required super.eligible,
    required super.documentStatus,
    required super.badgeActive,
    required super.requiresPurchase,
    required super.requiresDocumentReview,
    super.action,
    super.badgeKind,
    super.badgeCollegeName,
    super.currentRequest,
  });

  factory VerificationEligibilityModel.fromJson(Map<String, dynamic> json) {
    return VerificationEligibilityModel(
      eligible: JsonParser.boolean(json['eligible']),
      documentStatus: documentStatusFrom(
        JsonParser.nullableString(json['documentStatus']),
      ),
      badgeActive: JsonParser.boolean(json['badgeActive']),
      requiresPurchase: JsonParser.boolean(json['requiresPurchase']),
      requiresDocumentReview: JsonParser.boolean(
        json['requiresDocumentReview'],
      ),
      action: _action(JsonParser.nullableString(json['action'])),
      badgeKind: JsonParser.nullableString(json['badgeKind']),
      badgeCollegeName: JsonParser.nullableString(json['badgeCollegeName']),
      currentRequest: VerificationRequestModel.currentFromJson(
        json['currentVerificationRequest'],
      ),
    );
  }

  /// Reads `{data: {eligible, documentStatus, action, ...}}`
  /// (`GET verifications/eligibility`).
  static VerificationEligibilityModel dataFromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    return VerificationEligibilityModel.fromJson(JsonParser.map(root['data']));
  }

  /// `NOT_SUBMITTED | PENDING | NEEDS_CHANGES | APPROVED | REJECTED | REVOKED`.
  /// Also used by `CandidateVerificationModel`.
  static VerificationDocumentStatus documentStatusFrom(String? value) =>
      switch (value?.toUpperCase()) {
        'PENDING' => VerificationDocumentStatus.pending,
        'NEEDS_CHANGES' => VerificationDocumentStatus.needsChanges,
        'APPROVED' => VerificationDocumentStatus.approved,
        'REJECTED' => VerificationDocumentStatus.rejected,
        'REVOKED' => VerificationDocumentStatus.revoked,
        _ => VerificationDocumentStatus.notSubmitted,
      };

  /// `FIRST_TIME_VERIFICATION | REVERIFICATION | PENDING_REVIEW | RENEW`.
  static VerificationEligibilityAction? _action(String? value) =>
      switch (value?.toUpperCase()) {
        'FIRST_TIME_VERIFICATION' =>
          VerificationEligibilityAction.firstTimeVerification,
        'REVERIFICATION' => VerificationEligibilityAction.reverification,
        'PENDING_REVIEW' => VerificationEligibilityAction.pendingReview,
        'RENEW' => VerificationEligibilityAction.renew,
        _ => null,
      };
}
