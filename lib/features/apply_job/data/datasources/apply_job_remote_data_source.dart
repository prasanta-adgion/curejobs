import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/application_eligibility.dart';
import '../models/application_eligibility_model.dart';

abstract interface class ApplyJobRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<ApplicationEligibilityModel> getEligibility(String jobId);

  /// Sends the application for [jobId] with [resumeId] and the answers.
  Future<void> submitApplication({
    required String jobId,
    required String resumeId,
    required List<ScreeningAnswer> answers,
  });
}

class ApplyJobRemoteDataSourceImpl implements ApplyJobRemoteDataSource {
  final ApiClient _client;

  const ApplyJobRemoteDataSourceImpl(this._client);

  @override
  Future<ApplicationEligibilityModel> getEligibility(String jobId) {
    return _client.get<ApplicationEligibilityModel>(
      ApiEndpoints.jobApplicationEligibility(id: jobId),
      decoder: ApplicationEligibilityModel.fromJson,
    );
  }

  @override
  Future<void> submitApplication({
    required String jobId,
    required String resumeId,
    required List<ScreeningAnswer> answers,
  }) {
    return _client.post<void>(
      ApiEndpoints.jobApplicationSubmit(jobId: jobId),
      body: {
        'resumeId': resumeId,
        'screeningAnswers': [
          for (final a in answers)
            {
              'questionId': a.questionId,
              if (a.optionId != null) 'optionId': a.optionId,
              if (a.text != null) 'answerText': a.text,
            },
        ],
      },
      decoder: (_) {},
    );
  }
}
