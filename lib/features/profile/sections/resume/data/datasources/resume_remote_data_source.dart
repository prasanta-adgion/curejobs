import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../models/resume_model.dart';

abstract interface class ResumeRemoteDataSource {
  /// All methods throw a `Failure` on error (see [ApiClient]).
  Future<List<ResumeModel>> getResumes();

  /// Makes [resumeId] the default CV.
  Future<void> setDefault({required String resumeId});

  Future<void> deleteResume({required String resumeId});

  /// Saves an uploaded file (by [fileId]) as a new CV.
  Future<void> createResume({
    required String title,
    required String fileId,
    required bool isDefault,
  });
}

class ResumeRemoteDataSourceImpl implements ResumeRemoteDataSource {
  final ApiClient _client;

  const ResumeRemoteDataSourceImpl(this._client);

  @override
  Future<List<ResumeModel>> getResumes() {
    return _client.get<List<ResumeModel>>(
      ApiEndpoints.resumes,
      decoder: ResumeModel.listFromJson,
    );
  }

  @override
  Future<void> setDefault({required String resumeId}) {
    return _client.post<void>(
      ApiEndpoints.setDefaultResume(cvId: resumeId),
      decoder: (_) {},
    );
  }

  @override
  Future<void> deleteResume({required String resumeId}) {
    return _client.delete<void>(
      ApiEndpoints.deleteResume(cvId: resumeId),
      decoder: (_) {},
    );
  }

  @override
  Future<void> createResume({
    required String title,
    required String fileId,
    required bool isDefault,
  }) {
    return _client.post<void>(
      ApiEndpoints.resumes,
      body: {
        'title': title,
        'contentJson': <String, dynamic>{},
        'generatedFileId': fileId,
        'isDefault': isDefault,
      },
      decoder: (_) {},
    );
  }
}
