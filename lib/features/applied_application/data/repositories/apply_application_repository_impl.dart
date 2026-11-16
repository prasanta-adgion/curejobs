import '../../../../core/result/result.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/apply_application_repository.dart';
import '../datasources/apply_application_remote_data_source.dart';

class ApplyApplicationRepositoryImpl implements ApplyApplicationRepository {
  final ApplyApplicationRemoteDataSource _remote;

  const ApplyApplicationRepositoryImpl(this._remote);

  @override
  Future<Result<ApplicationsPage>> getMyApplications({
    required int page,
    required int limit,
    ApplicationStatus? status,
  }) {
    return Result.guard(
      () => _remote.getMyApplications(
        page: page,
        limit: limit,
        status: status?.apiValue,
      ),
    );
  }

  @override
  Future<Result<void>> withdrawApplication(String id) {
    return Result.guard(() => _remote.withdrawApplication(id));
  }
}
