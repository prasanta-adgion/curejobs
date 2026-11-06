import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/candidate.dart';
import '../../domain/usecases/get_candidate_profile_usecase.dart';
import '../../domain/usecases/get_profile_photo_url_usecase.dart';

part 'candidate_profile_event.dart';
part 'candidate_profile_state.dart';

/// Loads the signed-in candidate's profile for the profile screen.
class CandidateProfileBloc
    extends Bloc<CandidateProfileEvent, CandidateProfileState> {
  final GetCandidateProfileUseCase _getProfile;
  final GetProfilePhotoUrlUseCase _getPhotoUrl;

  CandidateProfileBloc(this._getProfile, this._getPhotoUrl)
    : super(const CandidateProfileState()) {
    on<CandidateProfileRequested>(_onRequested);
    on<CandidateProfilePhotoGet>(_onPhotoGet);
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
        photoUrl: state.photoUrl,
      ),
    );

    final result = await _getProfile();

    await result.fold(
      (candidate) async {
        final fileId = candidate.profilePhotoFileId;
        final samePhoto = fileId == state.candidate?.profilePhotoFileId;

        // Show the profile now; the photo follows without holding it up.
        emit(
          CandidateProfileState(
            status: CandidateProfileStatus.success,
            candidate: candidate,
            photoUrl: fileId != null && samePhoto ? state.photoUrl : null,
          ),
        );

        if (fileId != null) await _loadPhoto(fileId, emit);
      },
      (failure) async => emit(
        CandidateProfileState(
          status: CandidateProfileStatus.failure,
          candidate: state.candidate,
          photoUrl: state.photoUrl,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _onPhotoGet(
    CandidateProfilePhotoGet event,
    Emitter<CandidateProfileState> emit,
  ) async {
    final result = await _getPhotoUrl(event.fileId);
    final url = result.valueOrNull;
    if (url == null) return;

    emit(
      CandidateProfileState(
        status: state.status,
        candidate: state.candidate,
        photoUrl: url,
        errorMessage: state.errorMessage,
      ),
    );
  }

  /// A failure here is not surfaced: the avatar just keeps showing initials.
  Future<void> _loadPhoto(
    String fileId,
    Emitter<CandidateProfileState> emit,
  ) async {
    final result = await _getPhotoUrl(fileId);
    final url = result.valueOrNull;

    // Ignore the answer if a reload replaced the photo in the meantime.
    if (url == null || state.candidate?.profilePhotoFileId != fileId) return;

    emit(
      CandidateProfileState(
        status: state.status,
        candidate: state.candidate,
        photoUrl: url,
        errorMessage: state.errorMessage,
      ),
    );
  }
}
