import '../../../../core/result/result.dart';
import '../entities/location_suggestion.dart';
import '../enums/location_type.dart';
import '../repositories/location_repository.dart';

/// Autocompletes a location of the given [LocationType] from user input.
class GetLocationSuggestionsUseCase {
  final LocationRepository _repository;

  const GetLocationSuggestionsUseCase(this._repository);

  Future<Result<List<LocationSuggestion>>> call({
    required LocationType type,
    required String query,
  }) {
    return _repository.getLocationSuggestions(type: type, query: query.trim());
  }
}
