import 'package:curejobs/core/utils/json_parser.dart';
import 'package:curejobs/features/media_preview/domain/entities/media_upload_data.dart';

class MediaUploadResponseDataModel extends MediaUploadData {
  const MediaUploadResponseDataModel({
    required super.fileId,
    required super.url,
    super.expiresAt,
  });

  /// Reads `{data: {fileId, uploadUrl, expiresAt}}`.
  factory MediaUploadResponseDataModel.fromJson(Map<String, dynamic> json) {
    final data = JsonParser.map(json['data']);
    final fileId = JsonParser.string(data['fileId']);
    final url = JsonParser.string(data['uploadUrl']);

    if (fileId.isEmpty || url.isEmpty) {
      throw const FormatException('Invalid file upload response');
    }

    return MediaUploadResponseDataModel(
      fileId: fileId,
      url: url,
      expiresAt: JsonParser.dateTime(data['expiresAt']),
    );
  }
}
