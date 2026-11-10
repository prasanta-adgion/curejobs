import '../../../../../core/result/result.dart';
import '../entities/registration_result.dart';

abstract interface class RegistrationRepository {
  Future<Result<RegistrationResult>> register({
    required String email,
    required String password,
  });
}
