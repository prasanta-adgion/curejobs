import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/match_privacy.dart';
import '../../domain/entities/profile_activity.dart';
import '../models/match_privacy_model.dart';
import '../models/profile_activity_model.dart';

abstract interface class ProfileVisibilityRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<MatchPrivacy> getMatchPrivacy();

  Future<MatchPrivacy> updateMatchPrivacy({
    required bool matchDiscoverable,
    required bool shareContactOnReveal,
  });

  Future<ProfileActivity> getProfileActivity();
}

class ProfileVisibilityRemoteDataSourceImpl
    implements ProfileVisibilityRemoteDataSource {
  final ApiClient _client;

  const ProfileVisibilityRemoteDataSourceImpl(this._client);

  @override
  Future<MatchPrivacy> getMatchPrivacy() {
    return _client.get<MatchPrivacy>(
      ApiEndpoints.matchPrivacy,
      decoder: MatchPrivacyModel.fromJson,
    );
  }

  @override
  Future<MatchPrivacy> updateMatchPrivacy({
    required bool matchDiscoverable,
    required bool shareContactOnReveal,
  }) {
    return _client.put<MatchPrivacy>(
      ApiEndpoints.matchPrivacy,
      body: MatchPrivacyModel.toUpdateJson(
        matchDiscoverable: matchDiscoverable,
        shareContactOnReveal: shareContactOnReveal,
      ),
      decoder: MatchPrivacyModel.fromJson,
    );
  }

  @override
  Future<ProfileActivity> getProfileActivity() {
    return _client.get<ProfileActivity>(
      ApiEndpoints.profileActivity,
      decoder: ProfileActivityModel.fromJson,
    );
  }
}
