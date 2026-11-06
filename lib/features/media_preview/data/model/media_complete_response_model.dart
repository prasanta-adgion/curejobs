import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/media_complete_data.dart';

class MediaCompleteResponseModel extends MediaCompleteData {
  const MediaCompleteResponseModel({
    required super.fileId,
    required super.status,
    required super.finalizedAt,
  });

  /// Reads `{data: {fileId, status, finalizedAt}}`.
  factory MediaCompleteResponseModel.fromJson(Map<String, dynamic> json) {
    final data = JsonParser.map(json['data']);
    final fileId = JsonParser.string(data['fileId']);
    final status = JsonParser.string(data['status']);
    final finalizedAt = JsonParser.dateTime(data['finalizedAt']);

    if (fileId.isEmpty || status.isEmpty || finalizedAt == null) {
      throw const FormatException('Invalid file completion response');
    }

    return MediaCompleteResponseModel(
      fileId: fileId,
      status: status,
      finalizedAt: finalizedAt,
    );
  }
}
