part of 'media_upload_bloc.dart';

sealed class MediaUploadEvent extends Equatable {
  const MediaUploadEvent();

  @override
  List<Object?> get props => [];
}

/// Start the upload, or start it again after a failure.
final class MediaUploadRequested extends MediaUploadEvent {
  final PickedFile file;
  final MediaUploadPurpose purpose;

  const MediaUploadRequested({required this.file, required this.purpose});

  @override
  List<Object?> get props => [file.path, purpose];
}

final class _MediaUploadProgressed extends MediaUploadEvent {
  final double progress;

  const _MediaUploadProgressed(this.progress);

  @override
  List<Object?> get props => [progress];
}
