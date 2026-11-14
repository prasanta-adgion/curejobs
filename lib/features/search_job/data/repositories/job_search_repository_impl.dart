import '../../../../core/result/result.dart';
import '../../../all_jobs/domain/entities/job_page.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/repositories/job_search_repository.dart';
import '../datasources/job_search_remote_data_source.dart';

class JobSearchRepositoryImpl implements JobSearchRepository {
  final JobSearchRemoteDataSource _remote;

  const JobSearchRepositoryImpl(this._remote);

  @override
  Future<Result<JobPage>> search({
    required SearchQuery query,
    required int page,
    required int limit,
  }) => Result.guard(
    () => _remote.search(query: query, page: page, limit: limit),
  );
}
