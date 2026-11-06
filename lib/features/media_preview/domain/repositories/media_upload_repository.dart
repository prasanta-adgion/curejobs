import 'package:dio/dio.dart';

import '../../../../core/result/result.dart';
import '../../../../core/services/picked_file.dart';
import '../entities/media_complete_data.dart';
import '../enums/media_upload_purpose.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class MediaUploadRepository {
  /// Runs all three upload steps. Succeeds only when the file is FINALIZED.
  Future<Result<MediaCompleteData>> upload({
    required PickedFile file,
    required MediaUploadPurpose purpose,
    required void Function(int sent, int total) onProgress,
    CancelToken? cancelToken,
  });
}
