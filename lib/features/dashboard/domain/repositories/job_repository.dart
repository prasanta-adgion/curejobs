import '../../../../core/result/result.dart';
import '../entities/job_page.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class JobRepository {
  Future<Result<JobPage>> getJobs({required int page, required int limit});
}
