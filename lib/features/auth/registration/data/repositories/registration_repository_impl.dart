import '../../../../../core/result/result.dart';
import '../../domain/entities/registration_result.dart';
import '../../domain/repositories/registration_repository.dart';
import '../datasources/registration_remote_data_source.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationRemoteDataSource _remote;

  const RegistrationRepositoryImpl(this._remote);

  @override
  Future<Result<RegistrationResult>> register({
    required String email,
    required String password,
  }) {
    return Result.guard(
      () => _remote.register(email: email, password: password),
    );
  }
}
