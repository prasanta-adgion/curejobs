import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/picked_file.dart';
import '../../domain/entities/media_complete_data.dart';
import '../../domain/enums/media_upload_purpose.dart';
import '../../domain/usecases/upload_media_usecase.dart';

part 'media_upload_event.dart';
part 'media_upload_state.dart';

/// Runs one file upload. Closing the bloc cancels it.
class MediaUploadBloc extends Bloc<MediaUploadEvent, MediaUploadState> {
  final UploadMediaUseCase _upload;
  final _cancelToken = CancelToken();

  MediaUploadBloc(this._upload) : super(const MediaUploadState()) {
    on<MediaUploadRequested>(_onRequested);
    on<_MediaUploadProgressed>(_onProgressed);
  }

  Future<void> _onRequested(
    MediaUploadRequested event,
    Emitter<MediaUploadState> emit,
  ) async {
    if (state.status == MediaUploadStatus.uploading) return;
    emit(const MediaUploadState(status: MediaUploadStatus.uploading));

    final result = await _upload(
      file: event.file,
      purpose: event.purpose,
      cancelToken: _cancelToken,
      onProgress: (sent, total) {
        if (!isClosed && total > 0) {
          add(_MediaUploadProgressed(sent / total));
        }
      },
    );
    if (isClosed) return;

    result.fold(
      (completed) => emit(
        MediaUploadState(
          status: MediaUploadStatus.success,
          progress: 1,
          result: completed,
        ),
      ),
      (failure) => emit(
        MediaUploadState(
          status: MediaUploadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  void _onProgressed(
    _MediaUploadProgressed event,
    Emitter<MediaUploadState> emit,
  ) {
    // A late progress update must not undo a finished upload.
    if (state.status != MediaUploadStatus.uploading) return;
    emit(
      MediaUploadState(
        status: MediaUploadStatus.uploading,
        progress: event.progress,
      ),
    );
  }

  @override
  Future<void> close() {
    _cancelToken.cancel();
    return super.close();
  }
}
