import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/candidate_verification.dart';
import 'verification_eligibility_model.dart';
import 'verification_request_model.dart';

class CandidateVerificationModel extends CandidateVerification {
  const CandidateVerificationModel({
    required super.documentStatus,
    required super.badgeActive,
    required super.requiresDocumentReview,
    super.documentVerifiedAt,
    super.documentRevokedAt,
    super.badgeSource,
    super.badgeKind,
    super.badgeCollegeName,
    super.badgeStartsAt,
    super.badgeExpiresAt,
    super.entitlementId,
    super.currentRequest,
  });

  factory CandidateVerificationModel.fromJson(Map<String, dynamic> json) {
    return CandidateVerificationModel(
      documentStatus: VerificationEligibilityModel.documentStatusFrom(
        JsonParser.nullableString(json['documentStatus']),
      ),
      badgeActive: JsonParser.boolean(json['badgeActive']),
      requiresDocumentReview: JsonParser.boolean(
        json['requiresDocumentReview'],
      ),
      documentVerifiedAt: JsonParser.dateTime(json['documentVerifiedAt']),
      documentRevokedAt: JsonParser.dateTime(json['documentRevokedAt']),
      badgeSource: JsonParser.nullableString(json['badgeSource']),
      badgeKind: JsonParser.nullableString(json['badgeKind']),
      badgeCollegeName: JsonParser.nullableString(json['badgeCollegeName']),
      badgeStartsAt: JsonParser.dateTime(json['badgeStartsAt']),
      badgeExpiresAt: JsonParser.dateTime(json['badgeExpiresAt']),
      entitlementId: JsonParser.nullableString(json['entitlementId']),
      currentRequest: VerificationRequestModel.currentFromJson(
        json['currentVerificationRequest'],
      ),
    );
  }

  /// Reads `{data: {documentStatus, badgeActive, ...}}`
  /// (`GET verifications/me`).
  static CandidateVerificationModel dataFromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    return CandidateVerificationModel.fromJson(JsonParser.map(root['data']));
  }
}
