import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/job_suggestion.dart';

class JobSuggestionModel extends JobSuggestion {
  const JobSuggestionModel({
    required super.id,
    required super.value,
    super.type,
    super.hint,
    super.jobCount,
    super.categoryId,
    super.specializationId,
  });

  factory JobSuggestionModel.fromJson(Map<String, dynamic> json) {
    final value = JsonParser.string(json['value']).trim();
    return JobSuggestionModel(
      id: JsonParser.string(json['id'], fallback: value),
      value: value,
      type: _type(JsonParser.string(json['type'])),
      hint: JsonParser.nullableString(json['hint']),
      jobCount: JsonParser.nullableInteger(json['jobCount']),
      categoryId: JsonParser.nullableString(json['categoryId']),
      specializationId: JsonParser.nullableString(json['specializationId']),
    );
  }

  /// Reads `{data: [...]}`, skipping items without text.
  static List<JobSuggestionModel> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    return [
      for (final item in JsonParser.list(root['data']))
        if (item is Map<String, dynamic>) JobSuggestionModel.fromJson(item),
    ].where((s) => s.value.isNotEmpty).toList();
  }

  static JobSuggestionType _type(String value) => switch (value.toUpperCase()) {
    'CATEGORY' => JobSuggestionType.category,
    'SPECIALIZATION' => JobSuggestionType.specialization,
    'TITLE' => JobSuggestionType.title,
    _ => JobSuggestionType.unknown,
  };
}
