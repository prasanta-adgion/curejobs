import '../../../../core/result/result.dart';
import '../../domain/entities/application_detail.dart';
import '../../domain/repositories/application_detail_repository.dart';
import '../datasources/application_detail_remote_data_source.dart';

class ApplicationDetailRepositoryImpl implements ApplicationDetailRepository {
  final ApplicationDetailRemoteDataSource _remote;

  const ApplicationDetailRepositoryImpl(this._remote);

  @override
  Future<Result<ApplicationDetail>> getApplication(String id) =>
      Result.guard(() => _remote.getApplication(id));
}
