import '../../../../core/result/result.dart';
import '../entities/match_privacy.dart';
import '../entities/profile_activity.dart';
import '../repositories/profile_visibility_repository.dart';

class GetMatchPrivacyUseCase {
  final ProfileVisibilityRepository _repository;

  const GetMatchPrivacyUseCase(this._repository);

  Future<Result<MatchPrivacy>> call() => _repository.getMatchPrivacy();
}

class UpdateMatchPrivacyUseCase {
  final ProfileVisibilityRepository _repository;

  const UpdateMatchPrivacyUseCase(this._repository);

  Future<Result<MatchPrivacy>> call({
    required bool matchDiscoverable,
    required bool shareContactOnReveal,
  }) => _repository.updateMatchPrivacy(
    matchDiscoverable: matchDiscoverable,
    shareContactOnReveal: shareContactOnReveal,
  );
}

class GetProfileActivityUseCase {
  final ProfileVisibilityRepository _repository;

  const GetProfileActivityUseCase(this._repository);

  Future<Result<ProfileActivity>> call() => _repository.getProfileActivity();
}
