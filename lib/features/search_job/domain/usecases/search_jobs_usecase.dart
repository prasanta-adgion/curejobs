import '../../../../core/result/result.dart';
import '../../../all_jobs/domain/entities/job_page.dart';
import '../entities/search_query.dart';
import '../repositories/job_search_repository.dart';

/// Loads one page of jobs matching a keyword and location.
class SearchJobsUseCase {
  static const pageSize = 10;

  final JobSearchRepository _repository;

  const SearchJobsUseCase(this._repository);

  Future<Result<JobPage>> call(
    SearchQuery query, {
    int page = 1,
    int limit = pageSize,
  }) =>
      _repository.search(query: query, page: page < 1 ? 1 : page, limit: limit);
}
