import '../../../../core/result/result.dart';
import '../entities/application_eligibility.dart';

abstract interface class ApplyJobRepository {
  Future<Result<ApplicationEligibility>> getEligibility(String jobId);

  Future<Result<void>> submitApplication({
    required String jobId,
    required String resumeId,
    required List<ScreeningAnswer> answers,
  });
}
