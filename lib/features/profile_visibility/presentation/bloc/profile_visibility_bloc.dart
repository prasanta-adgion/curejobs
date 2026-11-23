import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../../subscription_packages/domain/entities/subscription_package.dart';
import '../../../subscription_packages/domain/usecases/get_current_plan_usecase.dart';
import '../../domain/entities/match_privacy.dart';
import '../../domain/entities/profile_activity.dart';
import '../../domain/usecases/profile_visibility_usecases.dart';

part 'profile_visibility_event.dart';
part 'profile_visibility_state.dart';

/// Loads the current plan first, then only the sections the plan unlocks:
/// - `profileVisibility` → match privacy settings
/// - `resumeVisibility` → profile activity (employers who revealed you)
class ProfileVisibilityBloc
    extends Bloc<ProfileVisibilityEvent, ProfileVisibilityState> {
  ProfileVisibilityBloc({
    required GetCurrentPlanUseCase getCurrentPlan,
    required GetMatchPrivacyUseCase getMatchPrivacy,
    required UpdateMatchPrivacyUseCase updateMatchPrivacy,
    required GetProfileActivityUseCase getProfileActivity,
  }) : _getCurrentPlan = getCurrentPlan,
       _getMatchPrivacy = getMatchPrivacy,
       _updateMatchPrivacy = updateMatchPrivacy,
       _getProfileActivity = getProfileActivity,
       super(const ProfileVisibilityState()) {
    on<ProfileVisibilityRequested>(_onRequested);
    on<MatchDiscoverableToggled>(
      (e, emit) => _update(emit, matchDiscoverable: e.value),
    );
    on<ShareContactOnRevealToggled>(
      (e, emit) => _update(emit, shareContactOnReveal: e.value),
    );
  }

  final GetCurrentPlanUseCase _getCurrentPlan;
  final GetMatchPrivacyUseCase _getMatchPrivacy;
  final UpdateMatchPrivacyUseCase _updateMatchPrivacy;
  final GetProfileActivityUseCase _getProfileActivity;

  Future<void> _onRequested(
    ProfileVisibilityRequested event,
    Emitter<ProfileVisibilityState> emit,
  ) async {
    emit(state.copyWith(status: ProfileVisibilityStatus.loading));

    final planResult = await _getCurrentPlan();
    final plan = planResult.valueOrNull;
    if (plan == null) {
      emit(
        state.copyWith(
          status: ProfileVisibilityStatus.failure,
          failure: planResult.failureOrNull,
        ),
      );
      return;
    }

    final canProfile = plan.has(PackageFeature.profileVisibility);
    final canResume = plan.has(PackageFeature.resumeVisibility);

    // Only hit the endpoints the plan allows; run them together.
    final privacyFuture = canProfile ? _getMatchPrivacy() : null;
    final activityFuture = canResume ? _getProfileActivity() : null;
    final privacyResult = await privacyFuture;
    final activityResult = await activityFuture;

    // A section failing doesn't block the other one; surface the first error.
    final failure =
        privacyResult?.failureOrNull ?? activityResult?.failureOrNull;

    emit(
      ProfileVisibilityState(
        status: ProfileVisibilityStatus.success,
        planName: plan.package.name,
        hasProfileVisibility: canProfile,
        hasResumeVisibility: canResume,
        privacy: privacyResult?.valueOrNull,
        activity: activityResult?.valueOrNull,
        failure: failure,
      ),
    );
  }

  Future<void> _update(
    Emitter<ProfileVisibilityState> emit, {
    bool? matchDiscoverable,
    bool? shareContactOnReveal,
  }) async {
    final previous = state.privacy;
    // One save at a time; both switches are locked while it runs.
    if (previous == null || !state.hasProfileVisibility || state.isSaving) {
      return;
    }

    // PUT replaces both settings, so send the full updated pair.
    final next = previous.copyWith(
      matchDiscoverable: matchDiscoverable,
      shareContactOnReveal: shareContactOnReveal,
    );

    // Optimistic: flip now, roll back if the server refuses.
    emit(
      state.copyWith(
        privacy: next,
        savingSetting: matchDiscoverable != null
            ? PrivacySetting.discoverable
            : PrivacySetting.shareContact,
        clearUpdateFailure: true,
      ),
    );

    final result = await _updateMatchPrivacy(
      matchDiscoverable: next.matchDiscoverable,
      shareContactOnReveal: next.shareContactOnReveal,
    );
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(privacy: value, clearSaving: true));
      case Err(:final failure):
        emit(
          state.copyWith(
            privacy: previous,
            clearSaving: true,
            updateFailure: failure,
          ),
        );
    }
  }
}
