import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/usecases/get_resume_file_url_usecase.dart';

part 'resume_viewer_event.dart';
part 'resume_viewer_state.dart';

/// Resolves the signed URL the viewer loads the resume PDF from. Retrying
/// always fetches a fresh URL, since the old one may have expired.
class ResumeViewerBloc extends Bloc<ResumeViewerEvent, ResumeViewerState> {
  final GetResumeFileUrlUseCase _getFileUrl;

  ResumeViewerBloc({required GetResumeFileUrlUseCase getFileUrl})
    : _getFileUrl = getFileUrl,
      super(const ResumeViewerState()) {
    on<ResumeViewerUrlRequested>(_onUrlRequested);
  }

  Future<void> _onUrlRequested(
    ResumeViewerUrlRequested event,
    Emitter<ResumeViewerState> emit,
  ) async {
    if (state.status == ResumeViewerStatus.loading) return;
    emit(const ResumeViewerState(status: ResumeViewerStatus.loading));

    final result = await _getFileUrl(event.fileId);
    result.fold(
      (url) =>
          emit(ResumeViewerState(status: ResumeViewerStatus.ready, url: url)),
      (failure) => emit(
        ResumeViewerState(status: ResumeViewerStatus.failure, failure: failure),
      ),
    );
  }
}
