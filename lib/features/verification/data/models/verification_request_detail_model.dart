import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/verification_request_detail.dart';
import 'verification_eligibility_model.dart';
import 'verification_request_model.dart';

class VerificationDocumentModel extends VerificationDocument {
  const VerificationDocumentModel({
    required super.id,
    required super.documentTypeId,
    required super.fileId,
    required super.status,
    super.reviewNote,
    super.createdAt,
    super.updatedAt,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentModel(
      id: JsonParser.string(json['id']),
      documentTypeId: JsonParser.string(json['documentTypeId']),
      fileId: JsonParser.string(json['fileId']),
      status: VerificationEligibilityModel.documentStatusFrom(
        JsonParser.nullableString(json['status']),
      ),
      reviewNote: JsonParser.nullableString(json['reviewNote']),
      createdAt: JsonParser.dateTime(json['createdAt']),
      updatedAt: JsonParser.dateTime(json['updatedAt']),
    );
  }
}

class VerificationRequestDetailModel extends VerificationRequestDetail {
  const VerificationRequestDetailModel({
    required super.id,
    required super.status,
    required super.documents,
    super.requestType,
    super.submittedAt,
    super.reviewedAt,
    super.rejectionReason,
  });

  factory VerificationRequestDetailModel.fromJson(Map<String, dynamic> json) {
    final documents = JsonParser.list(json['documents']);

    return VerificationRequestDetailModel(
      id: JsonParser.string(json['id']),
      requestType: VerificationRequestModel.requestTypeFrom(
        JsonParser.nullableString(json['requestType']),
      ),
      status: VerificationEligibilityModel.documentStatusFrom(
        JsonParser.nullableString(json['status']),
      ),
      submittedAt: JsonParser.dateTime(json['submittedAt']),
      reviewedAt: JsonParser.dateTime(json['reviewedAt']),
      rejectionReason: JsonParser.nullableString(json['rejectionReason']),
      documents: [
        for (final item in documents)
          if (item is Map<String, dynamic>)
            VerificationDocumentModel.fromJson(item),
      ],
    );
  }

  /// Reads `{data: {id, status, rejectionReason, documents: [...], ...}}`
  /// (`GET verifications/{id}`, `POST verifications/{id}/submit`).
  static VerificationRequestDetailModel dataFromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    return VerificationRequestDetailModel.fromJson(
      JsonParser.map(root['data']),
    );
  }
}
