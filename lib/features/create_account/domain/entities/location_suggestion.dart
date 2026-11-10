import 'package:equatable/equatable.dart';

import '../enums/location_type.dart';

/// One autocomplete result, e.g. "new town — kolkata, West Bengal".
class LocationSuggestion extends Equatable {
  final String id;
  final LocationType? type;
  final String value;
  final String? city;
  final String? state;
  final String? country;
  final String displayLabel;

  const LocationSuggestion({
    required this.id,
    required this.type,
    required this.value,
    required this.displayLabel,
    this.city,
    this.state,
    this.country,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    value,
    city,
    state,
    country,
    displayLabel,
  ];
}
