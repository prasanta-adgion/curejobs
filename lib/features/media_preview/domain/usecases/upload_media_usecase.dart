import 'package:dio/dio.dart';

import '../../../../core/result/result.dart';
import '../../../../core/services/picked_file.dart';
import '../entities/media_complete_data.dart';
import '../enums/media_upload_purpose.dart';
import '../repositories/media_upload_repository.dart';

/// Uploads a picked file and confirms it was finalized.
class UploadMediaUseCase {
  final MediaUploadRepository _repository;

  const UploadMediaUseCase(this._repository);

  Future<Result<MediaCompleteData>> call({
    required PickedFile file,
    required MediaUploadPurpose purpose,
    required void Function(int sent, int total) onProgress,
    CancelToken? cancelToken,
  }) {
    return _repository.upload(
      file: file,
      purpose: purpose,
      onProgress: onProgress,
      cancelToken: cancelToken,
    );
  }
}
