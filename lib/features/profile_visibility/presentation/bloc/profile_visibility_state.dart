part of 'profile_visibility_bloc.dart';

enum ProfileVisibilityStatus { loading, success, failure }

/// The match-privacy switch whose save is in flight.
enum PrivacySetting { discoverable, shareContact }

class ProfileVisibilityState extends Equatable {
  const ProfileVisibilityState({
    this.status = ProfileVisibilityStatus.loading,
    this.planName,
    this.hasProfileVisibility = false,
    this.hasResumeVisibility = false,
    this.privacy,
    this.activity,
    this.savingSetting,
    this.failure,
    this.updateFailure,
  });

  final ProfileVisibilityStatus status;
  final String? planName;

  /// Plan feature flags.
  final bool hasProfileVisibility;
  final bool hasResumeVisibility;

  /// Loaded only when the matching feature is on.
  final MatchPrivacy? privacy;
  final ProfileActivity? activity;

  /// Non-null while that switch is being saved; it shows a spinner.
  final PrivacySetting? savingSetting;

  bool get isSaving => savingSetting != null;

  /// Load failure (plan, or one of the sections).
  final Failure? failure;

  /// Last failed toggle; shown once as a snackbar.
  final Failure? updateFailure;

  ProfileVisibilityState copyWith({
    ProfileVisibilityStatus? status,
    MatchPrivacy? privacy,
    PrivacySetting? savingSetting,
    bool clearSaving = false,
    Failure? failure,
    Failure? updateFailure,
    bool clearUpdateFailure = false,
  }) {
    return ProfileVisibilityState(
      status: status ?? this.status,
      planName: planName,
      hasProfileVisibility: hasProfileVisibility,
      hasResumeVisibility: hasResumeVisibility,
      privacy: privacy ?? this.privacy,
      activity: activity,
      savingSetting: clearSaving ? null : savingSetting ?? this.savingSetting,
      failure: failure ?? this.failure,
      updateFailure: clearUpdateFailure
          ? null
          : updateFailure ?? this.updateFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    planName,
    hasProfileVisibility,
    hasResumeVisibility,
    privacy,
    activity,
    savingSetting,
    failure,
    updateFailure,
  ];
}
