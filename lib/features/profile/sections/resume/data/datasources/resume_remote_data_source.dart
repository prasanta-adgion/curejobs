import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../../../../../core/utils/json_parser.dart';
import '../models/resume_model.dart';

abstract interface class ResumeRemoteDataSource {
  /// All methods throw a `Failure` on error (see [ApiClient]).
  Future<List<ResumeModel>> getResumes();

  /// Short-lived signed URL for a file.
  Future<String> getFileAccessUrl({required String fileId});

  /// Makes [resumeId] the default CV.
  Future<void> setDefault({required String resumeId});

  Future<void> deleteResume({required String resumeId});
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
}
