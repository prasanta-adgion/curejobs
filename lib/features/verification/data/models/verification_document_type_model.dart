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
  static List<VerificationDocumentType> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    final items = JsonParser.list(
      root.containsKey('data') ? root['data'] : json,
    );
    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          VerificationDocumentTypeModel.fromJson(item),
    ];
  }
}
