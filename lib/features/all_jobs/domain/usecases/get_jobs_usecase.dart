import '../../../../core/result/result.dart';
import '../entities/job_feed.dart';
import '../entities/job_page.dart';
import '../repositories/job_repository.dart';

/// Loads one page of jobs from the given [JobFeed].
class GetJobsUseCase {
  static const defaultPageSize = 10;

  final JobRepository _repository;

  const GetJobsUseCase(this._repository);

  Future<Result<JobPage>> call({
    required JobFeed feed,
    int page = 1,
    int limit = defaultPageSize,
  }) {
    return _repository.getJobs(
      feed: feed,
      page: page < 1 ? 1 : page,
      limit: limit,
    );
  }
}
