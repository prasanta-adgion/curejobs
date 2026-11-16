import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/usecases/get_file_access_url_usecase.dart';

part 'file_access_state.dart';

/// Resolves a file id to a signed URL for a screen whose only job is showing
/// that file (see `FileViewerPage`). Blocs that need a URL as one step of
/// their own work call [GetFileAccessUrlUseCase] directly instead.
class FileAccessCubit extends Cubit<FileAccessState> {
  final GetFileAccessUrlUseCase _getFileUrl;

  FileAccessCubit(this._getFileUrl) : super(const FileAccessState());

  /// Always fetches a fresh URL, since they expire; also used for retry.
  Future<void> load(String fileId) async {
    if (state.status == FileAccessStatus.loading) return;
    emit(const FileAccessState(status: FileAccessStatus.loading));

    final result = await _getFileUrl(fileId);
    if (isClosed) return;
    result.fold(
      (url) => emit(FileAccessState(status: FileAccessStatus.ready, url: url)),
      (failure) => emit(
        FileAccessState(status: FileAccessStatus.failure, failure: failure),
      ),
    );
  }
}
