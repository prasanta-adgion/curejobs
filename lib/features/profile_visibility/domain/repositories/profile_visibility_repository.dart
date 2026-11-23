import '../../../../core/result/result.dart';
import '../entities/match_privacy.dart';
import '../entities/profile_activity.dart';

abstract interface class ProfileVisibilityRepository {
  Future<Result<MatchPrivacy>> getMatchPrivacy();

  Future<Result<MatchPrivacy>> updateMatchPrivacy({
    required bool matchDiscoverable,
    required bool shareContactOnReveal,
  });

  Future<Result<ProfileActivity>> getProfileActivity();
}
