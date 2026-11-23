import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/organization_details.dart';

class OrganizationDetailsModel extends OrganizationDetails {
  const OrganizationDetailsModel({
    required super.id,
    required super.name,
    required super.slug,
    super.type,
    super.description,
    super.logoFileId,
    super.website,
    super.city,
    super.state,
    super.country,
    super.verified,
  });

  /// Reads `{data: {id, name, slug, description, logoFileId, ...}}`.
  factory OrganizationDetailsModel.fromJson(Object? json) {
    final data = JsonParser.map(JsonParser.map(json)['data']);
    final id = JsonParser.string(data['id']);
    if (id.isEmpty) {
      throw const FormatException('Invalid organization response');
    }
    return OrganizationDetailsModel(
      id: id,
      name: JsonParser.string(data['name']).trim(),
      slug: JsonParser.string(data['slug']),
      type: JsonParser.nullableString(data['type']),
      description: JsonParser.nullableString(data['description'])?.trim(),
      logoFileId: JsonParser.nullableString(data['logoFileId']),
      website: JsonParser.nullableString(data['website'])?.trim(),
      city: JsonParser.nullableString(data['city']),
      state: JsonParser.nullableString(data['state']),
      country: JsonParser.nullableString(data['country']),
      verified: JsonParser.boolean(data['verified']),
    );
  }
}
