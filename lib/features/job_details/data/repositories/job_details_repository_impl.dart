import '../../../../core/result/result.dart';
import '../../domain/repositories/job_details_repository.dart';
import '../datasources/job_details_remote_data_source.dart';

class JobDetailsRepositoryImpl implements JobDetailsRepository {
  final JobDetailsRemoteDataSource _remote;

  const JobDetailsRepositoryImpl(this._remote);

  @override
  Future<Result<void>> trackJobView({
    required String jobId,
    required String listingContext,
  }) {
    return Result.guard(
      () => _remote.trackJobView(jobId: jobId, listingContext: listingContext),
    );
  }
}
