import 'package:curejobs/core/network/api_client.dart';
import 'package:curejobs/core/network/api_endpoints.dart';
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
}
