import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/candidate.dart';

class CandidateModel extends Candidate {
  const CandidateModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.professionalTitle,
    super.professionalSummary,
    super.profilePhotoFileId,
    super.primaryCategoryId,
    super.primarySpecializationId,
    super.address,
    super.city,
    super.state,
    super.country,
    super.postalCode,
    super.profileCompletionPercent,
    super.verification,
  });

  /// Accepts `{data: {...}}` or a bare candidate object.
  factory CandidateModel.fromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;

    return CandidateModel(
      id: JsonParser.string(data['id']),
      firstName: JsonParser.string(data['firstName']),
      lastName: JsonParser.string(data['lastName']),
      professionalTitle: JsonParser.nullableString(data['professionalTitle']),
      professionalSummary: JsonParser.nullableString(
        data['professionalSummary'],
      ),
      profilePhotoFileId: JsonParser.nullableString(data['profilePhotoFileId']),
      primaryCategoryId: JsonParser.nullableString(data['primaryCategoryId']),
      primarySpecializationId: JsonParser.nullableString(
        data['primarySpecializationId'],
      ),
      address: JsonParser.nullableString(
        data['address'] ?? data['addressLine1'],
      ),
      city: JsonParser.nullableString(data['city']),
      state: JsonParser.nullableString(data['state']),
      country: JsonParser.nullableString(data['country']),
      postalCode: JsonParser.nullableString(data['postalCode']),
      profileCompletionPercent: JsonParser.integer(
        data['profileCompletionPercent'],
      ).clamp(0, 100),
      verification: data['verification'] is Map<String, dynamic>
          ? CandidateVerificationModel.fromJson(
              data['verification'] as Map<String, dynamic>,
            )
          : const CandidateVerification(),
    );
  }
}

class CandidateVerificationModel extends CandidateVerification {
  const CandidateVerificationModel({
    super.documentStatus,
    super.badgeActive,
    super.badgeSource,
    super.badgeExpiresAt,
  });

  factory CandidateVerificationModel.fromJson(Map<String, dynamic> json) {
    return CandidateVerificationModel(
      documentStatus: _documentStatus(
        JsonParser.nullableString(json['documentStatus']),
      ),
      badgeActive: JsonParser.boolean(json['badgeActive']),
      badgeSource: JsonParser.nullableString(json['badgeSource']),
      badgeExpiresAt: JsonParser.dateTime(json['badgeExpiresAt']),
    );
  }

  static DocumentStatus _documentStatus(String? value) =>
      switch (value?.toUpperCase()) {
        'APPROVED' => DocumentStatus.approved,
        'PENDING' || 'SUBMITTED' || 'IN_REVIEW' => DocumentStatus.pending,
        'REJECTED' => DocumentStatus.rejected,
        _ => DocumentStatus.notSubmitted,
      };
}
