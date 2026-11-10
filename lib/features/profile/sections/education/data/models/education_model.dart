import '../../../../../../core/utils/json_parser.dart';
import '../../domain/entities/education.dart';

class EducationModel extends Education {
  const EducationModel({
    required super.id,
    required super.degree,
    required super.institution,
    super.fieldOfStudy,
    super.startYear,
    super.completionYear,
    super.currentlyStudying,
    super.description,
    super.sortOrder,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: JsonParser.string(json['id']),
      degree: JsonParser.string(json['degree']),
      institution: JsonParser.string(json['institution']),
      fieldOfStudy: JsonParser.nullableString(json['fieldOfStudy']),
      startYear: JsonParser.nullableInteger(json['startYear']),
      completionYear: JsonParser.nullableInteger(json['completionYear']),
      currentlyStudying: JsonParser.boolean(json['currentlyStudying']),
      description: JsonParser.nullableString(json['description']),
      sortOrder: JsonParser.integer(json['sortOrder']),
    );
  }

  /// Reads `{data: {items: [...]}}`, in `sortOrder` order.
  static List<EducationModel> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = JsonParser.map(root['data']);
    final items = JsonParser.list(data['items']);

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) EducationModel.fromJson(item),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
