import '../../../../core/result/result.dart';
import '../../domain/entities/application_eligibility.dart';
import '../../domain/repositories/apply_job_repository.dart';
import '../datasources/apply_job_remote_data_source.dart';

class ApplyJobRepositoryImpl implements ApplyJobRepository {
  final ApplyJobRemoteDataSource _remote;

  const ApplyJobRepositoryImpl(this._remote);

  @override
  Future<Result<ApplicationEligibility>> getEligibility(String jobId) {
    return Result.guard(() => _remote.getEligibility(jobId));
  }
}
