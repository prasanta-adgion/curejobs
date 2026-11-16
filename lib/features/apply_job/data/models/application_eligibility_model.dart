import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/application_eligibility.dart';

class ApplicationEligibilityModel extends ApplicationEligibility {
  const ApplicationEligibilityModel({
    required super.status,
    super.checks,
    super.questions,
  });

  /// Parses the full response body (`{ "data": { ... } }`).
  static ApplicationEligibilityModel fromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;

    return ApplicationEligibilityModel(
      status: EligibilityStatus.fromApi(JsonParser.string(data['status'])),
      checks: [
        for (final item in JsonParser.list(data['checks']))
          if (item is Map<String, dynamic>) _check(item),
      ],
      questions: [
        for (final item in JsonParser.list(data['questions']))
          if (item is Map<String, dynamic>) _question(item),
      ],
    );
  }

  static EligibilityCheck _check(Map<String, dynamic> json) => EligibilityCheck(
    code: JsonParser.string(json['code']),
    status: CheckStatus.fromApi(JsonParser.string(json['status'])),
    message: JsonParser.string(json['message']),
  );

  static ScreeningQuestion _question(Map<String, dynamic> json) =>
      ScreeningQuestion(
        id: JsonParser.string(json['id']),
        type: QuestionType.fromApi(JsonParser.string(json['type'])),
        prompt: JsonParser.string(json['prompt']),
        required: JsonParser.boolean(json['required']),
        maxAnswerLength: JsonParser.nullableInteger(json['maxAnswerLength']),
        options: [
          for (final o in JsonParser.list(json['options']))
            if (o is Map<String, dynamic>)
              QuestionOption(
                id: JsonParser.string(o['id']),
                label: JsonParser.string(o['label']),
              ),
        ],
      );
}
