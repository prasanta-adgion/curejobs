part of 'candidate_profile_bloc.dart';

enum CandidateProfileStatus { initial, loading, success, failure }

class CandidateProfileState extends Equatable {
  final CandidateProfileStatus status;

  /// Kept across reloads so a refresh never blanks the screen.
  final Candidate? candidate;
  final String? errorMessage;

  const CandidateProfileState({
    this.status = CandidateProfileStatus.initial,
    this.candidate,
    this.errorMessage,
  });

  bool get isLoading => status == CandidateProfileStatus.loading;

  @override
  List<Object?> get props => [status, candidate, errorMessage];
}
