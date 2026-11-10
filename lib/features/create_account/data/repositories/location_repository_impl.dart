import '../../../../core/result/result.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../domain/enums/location_type.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource _remote;

  const LocationRepositoryImpl(this._remote);

  @override
  Future<Result<List<LocationSuggestion>>> getLocationSuggestions({
    required LocationType type,
    required String query,
  }) {
    return Result.guard(
      () => _remote.getLocationSuggestions(type: type, query: query),
    );
  }
}
