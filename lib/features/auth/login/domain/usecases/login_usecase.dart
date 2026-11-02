import '../../../../../core/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Signs a user in with email and password.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}
