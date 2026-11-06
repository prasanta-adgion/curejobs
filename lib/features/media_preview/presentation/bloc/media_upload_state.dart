part of 'media_upload_bloc.dart';

enum MediaUploadStatus { initial, uploading, success, failure }

class MediaUploadState extends Equatable {
  final MediaUploadStatus status;

  /// 0 to 1, for the transfer to S3.
  final double progress;

  /// Set on success.
  final MediaCompleteData? result;

  /// Set on failure.
  final String? errorMessage;

  const MediaUploadState({
    this.status = MediaUploadStatus.initial,
    this.progress = 0,
    this.result,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, progress, result, errorMessage];
}
