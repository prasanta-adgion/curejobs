import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/enums/location_type.dart';
import '../models/location_suggestion_model.dart';

abstract interface class LocationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<LocationSuggestionModel>> getLocationSuggestions({
    required LocationType type,
    required String query,
  });
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient _client;

  const LocationRemoteDataSourceImpl(this._client);

  @override
  Future<List<LocationSuggestionModel>> getLocationSuggestions({
    required LocationType type,
    required String query,
  }) {
    return _client.get<List<LocationSuggestionModel>>(
      ApiEndpoints.locationSuggestions,
      queryParameters: {'type': type.apiValue, 'q': query},
      decoder: LocationSuggestionModel.listFromJson,
    );
  }
}
