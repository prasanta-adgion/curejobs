/// Granularity of a location suggestion; sent to the API as `type`.
enum LocationType {
  area('AREA'),
  city('CITY'),
  state('STATE'),
  country('COUNTRY');

  const LocationType(this.apiValue);

  final String apiValue;

  static LocationType? fromApi(String? value) {
    for (final type in values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }
}
