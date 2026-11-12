import '../../../../../../core/utils/json_parser.dart';
import '../../domain/entities/skill.dart';

class SkillModel extends Skill {
  const SkillModel({
    required super.id,
    required super.name,
    required super.normalizedName,
    super.createdAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    final name = JsonParser.string(json['name']).trim();
    final normalized = JsonParser.string(json['normalizedName']);
    return SkillModel(
      id: JsonParser.string(json['id']),
      name: name,
      normalizedName: normalized.isEmpty ? name.toLowerCase() : normalized,
      createdAt: JsonParser.dateTime(json['createdAt']),
    );
  }

  /// Reads `{data: {items: [...]}}`, oldest first so new skills show last.
  static List<SkillModel> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = JsonParser.map(root['data']);
    final items = JsonParser.list(data['items']);

    final skills = [
      for (final item in items)
        if (item is Map<String, dynamic>) SkillModel.fromJson(item),
    ].where((s) => s.name.isNotEmpty).toList();

    skills.sort((a, b) {
      final at = a.createdAt;
      final bt = b.createdAt;
      if (at == null || bt == null) return 0;
      return at.compareTo(bt);
    });
    return skills;
  }
}
