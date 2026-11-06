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
    super.area,
    super.address,
    super.city,
    super.state,
    super.country,
    super.postalCode,
    super.profileCompletionPercent,
    super.verification,
    super.createdAt,
    super.updatedAt,
  });

  /// Accepts:
  /// 1. {"data": {...}}
  /// 2. {...}
  factory CandidateModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid candidate response: expected a JSON object',
      );
    }

    final Object? payload = json.containsKey('data') ? json['data'] : json;

    if (payload is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid candidate response: data must be an object',
      );
    }

    final data = payload;

    final id = JsonParser.string(data['id']).trim();

    if (id.isEmpty) {
      throw const FormatException(
        'Invalid candidate response: missing candidate ID',
      );
    }

    return CandidateModel(
      id: id,
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
      area: JsonParser.nullableString(data['area']),
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
          : const CandidateVerificationModel(),
      createdAt: JsonParser.dateTime(data['createdAt']),
      updatedAt: JsonParser.dateTime(data['updatedAt']),
    );
  }

  /// Serializes the candidate into a bare JSON object.
  ///
  /// Does not include the API response's `data` wrapper.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'professionalTitle': professionalTitle,
      'professionalSummary': professionalSummary,
      'profilePhotoFileId': profilePhotoFileId,
      'primaryCategoryId': primaryCategoryId,
      'primarySpecializationId': primarySpecializationId,
      'area': area,
      if (address != null) 'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'profileCompletionPercent': profileCompletionPercent,
      'verification': CandidateVerificationModel.fromEntity(verification)
          .toJson(),
      'createdAt': createdAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Converts an existing domain entity into the data model.
  factory CandidateModel.fromEntity(Candidate candidate) {
    return CandidateModel(
      id: candidate.id,
      firstName: candidate.firstName,
      lastName: candidate.lastName,
      professionalTitle: candidate.professionalTitle,
      professionalSummary: candidate.professionalSummary,
      profilePhotoFileId: candidate.profilePhotoFileId,
      primaryCategoryId: candidate.primaryCategoryId,
      primarySpecializationId: candidate.primarySpecializationId,
      area: candidate.area,
      address: candidate.address,
      city: candidate.city,
      state: candidate.state,
      country: candidate.country,
      postalCode: candidate.postalCode,
      profileCompletionPercent: candidate.profileCompletionPercent,
      verification: candidate.verification,
      createdAt: candidate.createdAt,
      updatedAt: candidate.updatedAt,
    );
  }
}

class CandidateVerificationModel extends CandidateVerification {
  const CandidateVerificationModel({
    super.documentStatus,
    super.badgeActive,
    super.badgeSource,
    super.badgeKind,
    super.badgeCollegeName,
    super.badgeExpiresAt,
  });

  factory CandidateVerificationModel.fromJson(Map<String, dynamic> json) {
    return CandidateVerificationModel(
      documentStatus: _parseDocumentStatus(
        JsonParser.nullableString(json['documentStatus']),
      ),
      badgeActive: JsonParser.boolean(json['badgeActive']),
      badgeSource: JsonParser.nullableString(json['badgeSource']),
      badgeKind: JsonParser.nullableString(json['badgeKind']),
      badgeCollegeName: JsonParser.nullableString(json['badgeCollegeName']),
      badgeExpiresAt: JsonParser.dateTime(json['badgeExpiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentStatus': _documentStatusToJson(documentStatus),
      'badgeActive': badgeActive,
      'badgeSource': badgeSource,
      'badgeKind': badgeKind,
      'badgeCollegeName': badgeCollegeName,
      'badgeExpiresAt': badgeExpiresAt?.toUtc().toIso8601String(),
    };
  }

  factory CandidateVerificationModel.fromEntity(
    CandidateVerification verification,
  ) {
    return CandidateVerificationModel(
      documentStatus: verification.documentStatus,
      badgeActive: verification.badgeActive,
      badgeSource: verification.badgeSource,
      badgeKind: verification.badgeKind,
      badgeCollegeName: verification.badgeCollegeName,
      badgeExpiresAt: verification.badgeExpiresAt,
    );
  }

  static DocumentStatus _parseDocumentStatus(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'APPROVED' => DocumentStatus.approved,
      'PENDING' || 'SUBMITTED' || 'IN_REVIEW' => DocumentStatus.pending,
      'REJECTED' => DocumentStatus.rejected,
      _ => DocumentStatus.notSubmitted,
    };
  }

  static String _documentStatusToJson(DocumentStatus status) {
    return switch (status) {
      DocumentStatus.notSubmitted => 'NOT_SUBMITTED',
      DocumentStatus.pending => 'PENDING',
      DocumentStatus.approved => 'APPROVED',
      DocumentStatus.rejected => 'REJECTED',
    };
  }
}
