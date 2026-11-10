import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../domain/enums/location_type.dart';

class LocationSuggestionModel extends LocationSuggestion {
  const LocationSuggestionModel({
    required super.id,
    required super.type,
    required super.value,
    required super.displayLabel,
    super.city,
    super.state,
    super.country,
  });

  factory LocationSuggestionModel.fromJson(Map<String, dynamic> json) {
    final value = JsonParser.string(json['value']);
    return LocationSuggestionModel(
      id: JsonParser.string(json['id']),
      type: LocationType.fromApi(JsonParser.nullableString(json['type'])),
      value: value,
      city: JsonParser.nullableString(json['city']),
      state: JsonParser.nullableString(json['state']),
      country: JsonParser.nullableString(json['country']),
      displayLabel: JsonParser.string(json['displayLabel'], fallback: value),
    );
  }

  /// Reads `{data: [...]}`.
  static List<LocationSuggestionModel> listFromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    final items = JsonParser.list(root['data']);

    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          LocationSuggestionModel.fromJson(item),
    ];
  }
}
