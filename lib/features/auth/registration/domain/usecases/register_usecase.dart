import '../../../../../core/result/result.dart';
import '../entities/registration_result.dart';
import '../repositories/registration_repository.dart';

/// Creates a new candidate account with email and password.
class RegisterUseCase {
  final RegistrationRepository _repository;

  const RegisterUseCase(this._repository);

  Future<Result<RegistrationResult>> call({
    required String email,
    required String password,
  }) {
    return _repository.register(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}
