import 'package:curejobs/core/network/api_client.dart';
import 'package:curejobs/core/network/api_endpoints.dart';
import 'package:curejobs/core/utils/json_parser.dart';
import 'package:curejobs/features/media_preview/data/model/media_complete_response_model.dart';
import 'package:curejobs/features/media_preview/data/model/media_upload_response_data_model.dart';

abstract interface class ImageUploadRemoteDataSource {
  Future<MediaUploadResponseDataModel> initializeUpload({
    required String filename,
    required String mimeType,
    required String purpose,
    required int sizeBytes,
  });

  Future<MediaCompleteResponseModel> completeUpload({required String fileId});

  /// Short-lived signed URL for any uploaded file (photo, CV, document).
  Future<String> getFileAccessUrl({required String fileId});
}

class ImageUploadRemoteDataSourceImpl implements ImageUploadRemoteDataSource {
  final ApiClient _client;

  const ImageUploadRemoteDataSourceImpl(this._client);

  @override
  Future<MediaUploadResponseDataModel> initializeUpload({
    required String filename,
    required String mimeType,
    required String purpose,
    required int sizeBytes,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.uploadFile,
      body: {
        'filename': filename,
        'mimeType': mimeType,
        'purpose': purpose,
        'sizeBytes': sizeBytes,
      },
    );

    return MediaUploadResponseDataModel.fromJson(response);
  }

  @override
  Future<MediaCompleteResponseModel> completeUpload({
    required String fileId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.uploadFileComplete(fileId: fileId),
      body: <String, dynamic>{},
    );

    return MediaCompleteResponseModel.fromJson(response);
  }

  @override
  Future<String> getFileAccessUrl({required String fileId}) {
    return _client.get<String>(
      ApiEndpoints.getFileAccess(fileId: fileId),
      decoder: (json) {
        final data = JsonParser.map(JsonParser.map(json)['data']);
        final url = JsonParser.string(data['accessUrl']);
        if (url.isEmpty) {
          throw const FormatException('Invalid file access response');
        }
        return url;
      },
    );
  }
}
