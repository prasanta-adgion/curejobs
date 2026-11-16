import '../../../../core/result/result.dart';
import '../entities/application_eligibility.dart';

abstract interface class ApplyJobRepository {
  Future<Result<ApplicationEligibility>> getEligibility(String jobId);
}
