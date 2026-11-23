import '../../../../core/result/result.dart';
import '../../domain/entities/match_privacy.dart';
import '../../domain/entities/profile_activity.dart';
import '../../domain/repositories/profile_visibility_repository.dart';
import '../datasources/profile_visibility_remote_data_source.dart';

class ProfileVisibilityRepositoryImpl implements ProfileVisibilityRepository {
  final ProfileVisibilityRemoteDataSource _remote;

  const ProfileVisibilityRepositoryImpl(this._remote);

  @override
  Future<Result<MatchPrivacy>> getMatchPrivacy() =>
      Result.guard(_remote.getMatchPrivacy);

  @override
  Future<Result<MatchPrivacy>> updateMatchPrivacy({
    required bool matchDiscoverable,
    required bool shareContactOnReveal,
  }) => Result.guard(
    () => _remote.updateMatchPrivacy(
      matchDiscoverable: matchDiscoverable,
      shareContactOnReveal: shareContactOnReveal,
    ),
  );

  @override
  Future<Result<ProfileActivity>> getProfileActivity() =>
      Result.guard(_remote.getProfileActivity);
}
