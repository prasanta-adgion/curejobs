import 'package:equatable/equatable.dart';

/// Where to send a file. [url] is a presigned S3 URL.
class MediaUploadData extends Equatable {
  final String fileId;
  final String url;
  final DateTime? expiresAt;

  const MediaUploadData({
    required this.fileId,
    required this.url,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [fileId, url, expiresAt];
}
