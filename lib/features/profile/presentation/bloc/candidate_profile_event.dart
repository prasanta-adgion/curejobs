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
