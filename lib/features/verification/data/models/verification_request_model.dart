import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/verification_eligibility.dart';

class VerificationRequestModel extends VerificationRequest {
  const VerificationRequestModel({
    required super.id,
    required super.status,
    super.requestType,
    super.submittedAt,
  });

  factory VerificationRequestModel.fromJson(Map<String, dynamic> json) {
    return VerificationRequestModel(
      id: JsonParser.string(json['id']),
      status: JsonParser.string(json['status']),
      requestType: requestTypeFrom(
        JsonParser.nullableString(json['requestType']),
      ),
      submittedAt: JsonParser.dateTime(json['submittedAt']),
    );
  }

  /// Reads `{data: {id, requestType, status, submittedAt, ...}}`
  /// (`POST verifications`).
  static VerificationRequestModel dataFromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    return VerificationRequestModel.fromJson(JsonParser.map(root['data']));
  }

  /// Reads `currentVerificationRequest`; null when absent or without an id.
  static VerificationRequestModel? currentFromJson(Object? json) {
    final map = JsonParser.map(json);
    if (JsonParser.string(map['id']).isEmpty) return null;
    return VerificationRequestModel.fromJson(map);
  }

  /// `FIRST_TIME | REVERIFICATION`. Also used by the request detail model.
  static VerificationRequestType? requestTypeFrom(String? value) =>
      switch (value?.toUpperCase()) {
        'FIRST_TIME' => VerificationRequestType.firstTime,
        'REVERIFICATION' => VerificationRequestType.reverification,
        _ => null,
      };
}
