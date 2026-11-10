import '../../../../core/result/result.dart';
import '../entities/location_suggestion.dart';
import '../enums/location_type.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class LocationRepository {
  Future<Result<List<LocationSuggestion>>> getLocationSuggestions({
    required LocationType type,
    required String query,
  });
}
