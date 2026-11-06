import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';

abstract interface class S3UploadDataSource {
  Future<void> upload({
    required String presignedUrl,
    required Uint8List bytes,
    required String mimeType,
    required void Function(int sent, int total) onProgress,
    CancelToken? cancelToken,
  });
}

class S3UploadDataSourceImpl implements S3UploadDataSource {
  final Dio _dio;

  S3UploadDataSourceImpl(this._dio);

  @override
  Future<void> upload({
    required String presignedUrl,
    required Uint8List bytes,
    required String mimeType,
    required void Function(int sent, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final url = Uri.parse(presignedUrl);

    if (url.scheme != 'https' || !url.host.endsWith('.amazonaws.com')) {
      throw const UploadFailure();
    }

    final response = await _dio.putUri<void>(
      url,
      data: bytes,
      cancelToken: cancelToken,
      options: Options(
        contentType: mimeType,
        responseType: ResponseType.plain,
        followRedirects: false,
        headers: {
          Headers.contentLengthHeader: bytes.length,

          // Signed into the presigned URL, so it must be sent as is.
          'x-amz-server-side-encryption': 'AES256',
        },
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
      onSendProgress: onProgress,
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw const UploadFailure();
    }
  }
}
