import '../../../../core/result/result.dart';
import '../entities/job_page.dart';
import '../repositories/job_repository.dart';

/// Loads one page of published jobs.
class GetJobsUseCase {
  static const defaultPageSize = 10;

  final JobRepository _repository;

  const GetJobsUseCase(this._repository);

  Future<Result<JobPage>> call({int page = 1, int limit = defaultPageSize}) {
    return _repository.getJobs(page: page < 1 ? 1 : page, limit: limit);
  }
}
