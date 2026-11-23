import 'package:equatable/equatable.dart';

/// Public profile of an employer.
class OrganizationDetails extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? type;
  final String? description;
  final String? logoFileId;
  final String? website;
  final String? city;
  final String? state;
  final String? country;
  final bool verified;

  const OrganizationDetails({
    required this.id,
    required this.name,
    required this.slug,
    this.type,
    this.description,
    this.logoFileId,
    this.website,
    this.city,
    this.state,
    this.country,
    this.verified = false,
  });

  /// "New town, Kolkata, West Bengal, India", or null when nothing is set.
  String? get location {
    final parts = [city, state, country]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    type,
    description,
    logoFileId,
    website,
    city,
    state,
    country,
    verified,
  ];
}
