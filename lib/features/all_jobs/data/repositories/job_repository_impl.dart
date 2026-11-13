import '../../../../core/result/result.dart';
import '../../domain/entities/job_feed.dart';
import '../../domain/entities/job_page.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_data_source.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource _remote;

  const JobRepositoryImpl(this._remote);

  @override
  Future<Result<JobPage>> getJobs({
    required JobFeed feed,
    required int page,
    required int limit,
  }) {
    return Result.guard(
      () => _remote.getJobs(feed: feed, page: page, limit: limit),
    );
  }
}
