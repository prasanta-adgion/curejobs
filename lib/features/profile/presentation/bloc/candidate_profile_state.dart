part of 'candidate_profile_bloc.dart';

enum CandidateProfileStatus { initial, loading, success, failure }

class CandidateProfileState extends Equatable {
  final CandidateProfileStatus status;

  /// Kept across reloads so a refresh never blanks the screen.
  final Candidate? candidate;

  /// Signed URL of the candidate's photo. Null until it loads, or when there
  /// is no photo; the avatar then shows initials.
  final String? photoUrl;
  final String? errorMessage;

  const CandidateProfileState({
    this.status = CandidateProfileStatus.initial,
    this.candidate,
    this.photoUrl,
    this.errorMessage,
  });

  bool get isLoading => status == CandidateProfileStatus.loading;

  @override
  List<Object?> get props => [status, candidate, photoUrl, errorMessage];
}
