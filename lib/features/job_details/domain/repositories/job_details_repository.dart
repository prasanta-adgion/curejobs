import '../../../../core/result/result.dart';

abstract interface class JobDetailsRepository {
  Future<Result<void>> trackJobView({
    required String jobId,
    required String listingContext,
  });
}
