import '../../../../../../core/utils/json_parser.dart';
import '../../domain/entities/experience.dart';

class ExperienceModel extends Experience {
  const ExperienceModel({
    required super.id,
    required super.organizationName,
    required super.jobTitle,
    super.employmentType,
    super.startDate,
    super.endDate,
    super.currentlyWorking,
    super.location,
    super.responsibilities,
    super.sortOrder,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: JsonParser.string(json['id']),
      organizationName: JsonParser.string(json['organizationName']),
      jobTitle: JsonParser.string(json['jobTitle']),
      employmentType: JsonParser.nullableString(json['employmentType']),
      startDate: JsonParser.dateTime(json['startDate']),
      endDate: JsonParser.dateTime(json['endDate']),
      currentlyWorking: JsonParser.boolean(json['currentlyWorking']),
      location: JsonParser.nullableString(json['location']),
      responsibilities: JsonParser.nullableString(json['responsibilities']),
      sortOrder: JsonParser.integer(json['sortOrder']),
    );
  }

  /// Reads `{data: {items: [...]}}`, in `sortOrder` order.
  static List<ExperienceModel> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = JsonParser.map(root['data']);
    final items = JsonParser.list(data['items']);

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) ExperienceModel.fromJson(item),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
