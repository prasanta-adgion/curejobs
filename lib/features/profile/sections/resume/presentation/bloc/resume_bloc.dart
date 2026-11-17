import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/resume.dart';
import '../../domain/usecases/create_resume_usecase.dart';
import '../../domain/usecases/delete_resume_usecase.dart';
import '../../../../../media_preview/domain/usecases/get_file_access_url_usecase.dart';
import '../../domain/usecases/get_resumes_usecase.dart';
import '../../domain/usecases/set_default_resume_usecase.dart';

part 'resume_event.dart';
part 'resume_state.dart';

/// Loads the candidate's resumes and resolves a resume PDF's signed URL for
/// downloading, sets the default CV and deletes CVs. Viewing happens in `FileViewerPage`.
class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final GetResumesUseCase _getResumes;
  final GetFileAccessUrlUseCase _getFileUrl;
  final SetDefaultResumeUseCase _setDefault;
  final DeleteResumeUseCase _deleteResume;
  final CreateResumeUseCase _createResume;

  ResumeBloc({
    required GetResumesUseCase getResumes,
    required GetFileAccessUrlUseCase getFileUrl,
    required SetDefaultResumeUseCase setDefault,
    required DeleteResumeUseCase deleteResume,
    required CreateResumeUseCase createResume,
  }) : _getResumes = getResumes,
       _getFileUrl = getFileUrl,
       _setDefault = setDefault,
       _deleteResume = deleteResume,
       _createResume = createResume,
       super(const ResumeState()) {
    on<ResumesRequested>(_onRequested);
    on<ResumeDownloadRequested>(_onDownloadRequested);
    on<ResumeSetDefaultRequested>(_onSetDefaultRequested);
    on<ResumeDeleteRequested>(_onDeleteRequested);
    on<ResumeUploaded>(_onUploaded);
  }

  Future<void> _onRequested(
    ResumesRequested event,
    Emitter<ResumeState> emit,
  ) async {
    if (state.status == ResumeStatus.loading) return;
    emit(state.copyWith(status: ResumeStatus.loading));

    final result = await _getResumes();
    result.fold(
      (items) =>
          emit(state.copyWith(status: ResumeStatus.success, items: items)),
      (failure) =>
          emit(state.copyWith(status: ResumeStatus.failure, failure: failure)),
    );
  }

  /// Fetches a fresh signed URL each time, since they expire.
  Future<void> _onDownloadRequested(
    ResumeDownloadRequested event,
    Emitter<ResumeState> emit,
  ) async {
    final fileId = event.resume.generatedFileId;
    if (!event.resume.hasFile || state.downloadingId != null) return;
    emit(state.copyWith(downloadingId: event.resume.id));

    final result = await _getFileUrl(fileId!);
    result.fold(
      (url) => emit(state.copyWith(downloadUrl: url)),
      (failure) => emit(state.copyWith(actionFailure: failure)),
    );
  }

  /// Only one CV can be default, so on success every other CV is cleared
  /// locally and the list re-sorts with the new default first.
  Future<void> _onSetDefaultRequested(
    ResumeSetDefaultRequested event,
    Emitter<ResumeState> emit,
  ) async {
    final id = event.resume.id;
    if (event.resume.isDefault || state.settingDefaultId != null) return;
    emit(state.copyWith(settingDefaultId: id));

    final result = await _setDefault(id);
    result.fold(
      (_) => emit(
        state.copyWith(
          items: [
            for (final r in state.items) r.copyWith(isDefault: r.id == id),
          ],
          defaultChanged: true,
        ),
      ),
      (failure) => emit(state.copyWith(defaultFailure: failure)),
    );
  }

  /// Removes the CV from the list once the server confirms.
  Future<void> _onDeleteRequested(
    ResumeDeleteRequested event,
    Emitter<ResumeState> emit,
  ) async {
    final id = event.resume.id;
    if (state.deletingId != null) return;
    emit(state.copyWith(deletingId: id));

    final result = await _deleteResume(id);
    result.fold(
      (_) => emit(
        state.copyWith(
          items: [
            for (final r in state.items)
              if (r.id != id) r,
          ],
          deleted: true,
        ),
      ),
      (failure) => emit(state.copyWith(deleteFailure: failure)),
    );
  }

  /// Saves the CV, then reloads the list so it shows with server data.
  Future<void> _onUploaded(
    ResumeUploaded event,
    Emitter<ResumeState> emit,
  ) async {
    if (state.creating) return;
    emit(state.copyWith(creating: true));

    final result = await _createResume(
      title: event.title,
      fileId: event.fileId,
      isDefault: state.items.isEmpty,
    );
    await result.fold((_) async {
      emit(state.copyWith(created: true));
      final reloaded = await _getResumes();
      reloaded.fold(
        (items) =>
            emit(state.copyWith(status: ResumeStatus.success, items: items)),
        (_) {},
      );
    }, (failure) async => emit(state.copyWith(createFailure: failure)));
  }
}
