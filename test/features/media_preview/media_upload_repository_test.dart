import 'dart:io';
import 'dart:typed_data';

import 'package:curejobs/core/error/failure.dart';
import 'package:curejobs/core/services/picked_file.dart';
import 'package:curejobs/features/media_preview/data/datasource/image_upload_remote_datasource.dart';
import 'package:curejobs/features/media_preview/data/datasource/s3_upload_data_source.dart';
import 'package:curejobs/features/media_preview/data/model/media_complete_response_model.dart';
import 'package:curejobs/features/media_preview/data/model/media_upload_response_data_model.dart';
import 'package:curejobs/features/media_preview/data/repositories/media_upload_repository_impl.dart';
import 'package:curejobs/features/media_preview/domain/enums/media_upload_purpose.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemote implements ImageUploadRemoteDataSource {
  _FakeRemote(this.calls, {this.status = 'FINALIZED'});

  final List<String> calls;
  final String status;
  String? mimeType;
  String? purpose;

  @override
  Future<MediaUploadResponseDataModel> initializeUpload({
    required String filename,
    required String mimeType,
    required String purpose,
    required int sizeBytes,
  }) async {
    calls.add('init');
    this.mimeType = mimeType;
    this.purpose = purpose;
    return MediaUploadResponseDataModel.fromJson({
      'data': {'fileId': 'file-1', 'uploadUrl': 'https://s3.example/put'},
    });
  }

  @override
  Future<MediaCompleteResponseModel> completeUpload({
    required String fileId,
  }) async {
    calls.add('complete:$fileId');
    return MediaCompleteResponseModel(
      fileId: fileId,
      status: status,
      finalizedAt: DateTime(2026),
    );
  }
}

class _FakeS3 implements S3UploadDataSource {
  _FakeS3(this.calls, {this.error});

  final List<String> calls;
  final Object? error;

  @override
  Future<void> upload({
    required String presignedUrl,
    required Uint8List bytes,
    required String mimeType,
    required void Function(int sent, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    calls.add('put:$presignedUrl:$mimeType');
    if (error != null) throw error!;
  }
}

void main() {
  late Directory directory;
  late PickedFile file;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('upload_test');
    final path = '${directory.path}/photo.png';
    await File(path).writeAsBytes([1, 2, 3]);
    file = PickedFile(path: path, name: 'photo.png', sizeInBytes: 3);
  });

  tearDown(() => directory.delete(recursive: true));

  test('runs the three steps in order', () async {
    final calls = <String>[];
    final remote = _FakeRemote(calls);
    final result = await MediaUploadRepositoryImpl(remote, _FakeS3(calls))
        .upload(
          file: file,
          purpose: MediaUploadPurpose.profilePhoto,
          onProgress: (_, _) {},
        );

    expect(result.valueOrNull?.isFinalized, isTrue);
    expect(calls, [
      'init',
      'put:https://s3.example/put:image/png',
      'complete:file-1',
    ]);
    expect(remote.mimeType, 'image/png');
    expect(remote.purpose, 'PROFILE_PHOTO');
  });

  test('fails when the status is not FINALIZED', () async {
    final calls = <String>[];
    final result =
        await MediaUploadRepositoryImpl(
          _FakeRemote(calls, status: 'PENDING'),
          _FakeS3(calls),
        ).upload(
          file: file,
          purpose: MediaUploadPurpose.resume,
          onProgress: (_, _) {},
        );

    expect(result.failureOrNull, isA<UploadFailure>());
  });

  test('does not complete when S3 rejects the file', () async {
    final calls = <String>[];
    final s3Error = DioException.badResponse(
      statusCode: 403,
      requestOptions: RequestOptions(),
      response: Response(requestOptions: RequestOptions(), statusCode: 403),
    );
    final result =
        await MediaUploadRepositoryImpl(
          _FakeRemote(calls),
          _FakeS3(calls, error: s3Error),
        ).upload(
          file: file,
          purpose: MediaUploadPurpose.profilePhoto,
          onProgress: (_, _) {},
        );

    expect(result.failureOrNull, isA<UploadFailure>());
    expect(calls, hasLength(2));
  });
}
