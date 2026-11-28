import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/verification_document_type.dart';

class VerificationDocumentTypeModel extends VerificationDocumentType {
  const VerificationDocumentTypeModel({
    required super.id,
    required super.code,
    required super.name,
    required super.isRequired,
  });

  factory VerificationDocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return VerificationDocumentTypeModel(
      id: JsonParser.string(json['id']),
      code: JsonParser.string(json['code']),
      name: JsonParser.string(json['name']).trim(),
      isRequired: JsonParser.boolean(json['isRequired']),
    );
  }

  /// Reads `{data: [{id, code, name, isRequired}, ...]}`.
  static List<VerificationDocumentTypeModel> listFromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    final items = JsonParser.list(root['data']);

    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          VerificationDocumentTypeModel.fromJson(item),
    ];
  }
}
