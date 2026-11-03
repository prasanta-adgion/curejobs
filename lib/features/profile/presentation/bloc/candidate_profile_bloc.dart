import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/candidate.dart';
import '../../domain/usecases/get_candidate_profile_usecase.dart';

part 'candidate_profile_event.dart';
part 'candidate_profile_state.dart';

/// Loads the signed-in candidate's profile for the profile screen.
class CandidateProfileBloc
    extends Bloc<CandidateProfileEvent, CandidateProfileState> {
  final GetCandidateProfileUseCase _getProfile;

  CandidateProfileBloc(this._getProfile)
    : super(const CandidateProfileState()) {
    on<CandidateProfileRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CandidateProfileRequested event,
    Emitter<CandidateProfileState> emit,
  ) async {
    if (state.isLoading) return;
    emit(
      CandidateProfileState(
        status: CandidateProfileStatus.loading,
        candidate: state.candidate,
      ),
    );

    final result = await _getProfile();

    result.fold(
      (candidate) => emit(
        CandidateProfileState(
          status: CandidateProfileStatus.success,
          candidate: candidate,
        ),
      ),
      (failure) => emit(
        CandidateProfileState(
          status: CandidateProfileStatus.failure,
          candidate: state.candidate,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
