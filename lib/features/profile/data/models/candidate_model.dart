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
      id: data['id'].toString(),
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      professionalTitle: data['professionalTitle'] as String?,
      professionalSummary: data['professionalSummary'] as String?,
      profilePhotoFileId: data['profilePhotoFileId'] as String?,
      primaryCategoryId: data['primaryCategoryId'] as String?,
      primarySpecializationId: data['primarySpecializationId'] as String?,
      address: (data['address'] ?? data['addressLine1']) as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      country: data['country'] as String?,
      postalCode: data['postalCode'] as String?,
      profileCompletionPercent:
          (data['profileCompletionPercent'] as num?)?.round().clamp(0, 100) ??
          0,
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
    final expiresAt = json['badgeExpiresAt'] as String?;

    return CandidateVerificationModel(
      documentStatus: _documentStatus(json['documentStatus'] as String?),
      badgeActive: json['badgeActive'] as bool? ?? false,
      badgeSource: json['badgeSource'] as String?,
      badgeExpiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt),
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
