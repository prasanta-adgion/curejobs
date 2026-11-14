import '../../../../core/result/result.dart';
import '../../../all_jobs/domain/entities/job_page.dart';
import '../entities/search_query.dart';

abstract interface class JobSearchRepository {
  Future<Result<JobPage>> search({
    required SearchQuery query,
    required int page,
    required int limit,
  });
}
