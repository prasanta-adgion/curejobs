import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/verification_eligibility.dart';

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

  /// Reads `{data: {eligible, documentStatus, ..., currentVerificationRequest}}`.
  factory VerificationEligibilityModel.fromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;
    final request = JsonParser.map(data['currentVerificationRequest']);

    return VerificationEligibilityModel(
      eligible: JsonParser.boolean(data['eligible']),
      documentStatus: _documentStatus(
        JsonParser.nullableString(data['documentStatus']),
      ),
      badgeActive: JsonParser.boolean(data['badgeActive']),
      requiresPurchase: JsonParser.boolean(data['requiresPurchase']),
      requiresDocumentReview: JsonParser.boolean(
        data['requiresDocumentReview'],
      ),
      action: JsonParser.nullableString(data['action']),
      badgeKind: JsonParser.nullableString(data['badgeKind']),
      badgeCollegeName: JsonParser.nullableString(data['badgeCollegeName']),
      currentRequest: request.isEmpty
          ? null
          : VerificationRequestModel.fromJson(request),
    );
  }

  static VerificationDocumentStatus _documentStatus(String? value) =>
      switch (value?.toUpperCase()) {
        'PENDING' => VerificationDocumentStatus.pending,
        'APPROVED' => VerificationDocumentStatus.approved,
        'REJECTED' => VerificationDocumentStatus.rejected,
        _ => VerificationDocumentStatus.notSubmitted,
      };
}

class VerificationRequestModel extends VerificationRequest {
  const VerificationRequestModel({
    required super.id,
    required super.status,
    super.submittedAt,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: JsonParser.string(json['id']),
      status: JsonParser.string(json['status']),
      submittedAt: JsonParser.dateTime(json['submittedAt']),
    );
  }
}
