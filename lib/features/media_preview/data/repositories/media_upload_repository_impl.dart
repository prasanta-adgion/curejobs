import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/services/picked_file.dart';
import '../../domain/entities/media_complete_data.dart';
import '../../domain/enums/media_upload_purpose.dart';
import '../../domain/repositories/media_upload_repository.dart';
import '../datasource/image_upload_remote_datasource.dart';
import '../datasource/s3_upload_data_source.dart';

class MediaUploadRepositoryImpl implements MediaUploadRepository {
  final ImageUploadRemoteDataSource _remote;
  final S3UploadDataSource _s3;

  const MediaUploadRepositoryImpl(this._remote, this._s3);

  static const _mimeTypes = {
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'webp': 'image/webp',
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  @override
  Future<Result<MediaCompleteData>> upload({
    required PickedFile file,
    required MediaUploadPurpose purpose,
    required void Function(int sent, int total) onProgress,
    CancelToken? cancelToken,
  }) {
    return Result.guard(() async {
      final bytes = await File(file.path).readAsBytes();
      final mimeType = _mimeType(file.name);

      // 1. Ask the API where to upload.
      final target = await _remote.initializeUpload(
        filename: file.name,
        mimeType: mimeType,
        purpose: purpose.apiValue,
        sizeBytes: bytes.length,
      );

      // 2. Send the file to S3.
      try {
        await _s3.upload(
          presignedUrl: target.url,
          bytes: bytes,
          mimeType: mimeType,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );
      } on DioException catch (error) {
        // S3 rejected it. A 403 here isn't a permission problem of the user's.
        if (error.type == DioExceptionType.badResponse) {
          throw const UploadFailure();
        }
        rethrow;
      }

      // 3. Confirm it. Only FINALIZED means the upload is done.
      final completed = await _remote.completeUpload(fileId: target.fileId);
      if (!completed.isFinalized) throw const UploadFailure();
      return completed;
    });
  }

  static String _mimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    final mimeType = _mimeTypes[extension];
    if (mimeType == null) {
      throw const UploadFailure("This file type can't be uploaded.");
    }
    return mimeType;
  }
}
