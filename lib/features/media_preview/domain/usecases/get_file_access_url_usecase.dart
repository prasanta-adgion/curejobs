import '../../../../core/result/result.dart';
import '../repositories/media_upload_repository.dart';

/// Resolves any file id (profile photo, CV, document) to a short-lived
/// signed URL. Fetch a fresh one each time, since they expire.
class GetFileAccessUrlUseCase {
  final MediaUploadRepository _repository;

  const GetFileAccessUrlUseCase(this._repository);

  Future<Result<String>> call(String fileId) =>
      _repository.getFileAccessUrl(fileId: fileId);
}
