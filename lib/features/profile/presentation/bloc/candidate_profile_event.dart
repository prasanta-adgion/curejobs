part of 'candidate_profile_bloc.dart';

sealed class CandidateProfileEvent extends Equatable {
  const CandidateProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load the profile, or reload it after a failure.
final class CandidateProfileRequested extends CandidateProfileEvent {
  const CandidateProfileRequested();
}

/// A new photo was uploaded; show it without reloading the profile.
final class CandidateProfilePhotoGet extends CandidateProfileEvent {
  final String fileId;

  const CandidateProfilePhotoGet(this.fileId);

  @override
  List<Object?> get props => [fileId];
}
