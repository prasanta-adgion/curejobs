import '../../../../../../core/utils/json_parser.dart';
import '../../domain/entities/language.dart';

class LanguageModel extends Language {
  const LanguageModel({
    required super.id,
    required super.name,
    required super.proficiency,
    super.createdAt,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: JsonParser.string(json['id']),
      name: JsonParser.string(json['language']).trim(),
      proficiency: LanguageProficiency.fromApi(
        JsonParser.string(json['proficiency']),
      ),
      createdAt: JsonParser.dateTime(json['createdAt']),
    );
  }

  /// Reads `{data: {items: [...]}}`, oldest first so new ones show last.
  static List<LanguageModel> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = JsonParser.map(root['data']);
    final items = JsonParser.list(data['items']);

    final languages = [
      for (final item in items)
        if (item is Map<String, dynamic>) LanguageModel.fromJson(item),
    ].where((l) => l.name.isNotEmpty).toList();

    languages.sort((a, b) {
      final at = a.createdAt;
      final bt = b.createdAt;
      if (at == null || bt == null) return 0;
      return at.compareTo(bt);
    });
    return languages;
  }
}
