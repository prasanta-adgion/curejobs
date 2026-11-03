import '../../../../../core/network/session_manager.dart';
import '../../../../../core/result/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SessionManager _sessionManager;

  const AuthRepositoryImpl(this._remote, this._sessionManager);

  @override
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  }) {
    return Result.guard(() => _remote.login(email: email, password: password));
  }

  @override
  Future<Result<void>> logout() async {
    // A failed server call (offline, session already expired) must not keep
    // the user signed in, so the server result is not returned.
    await Result.guard(_remote.logout);
    return Result.guard(_sessionManager.logoutLocal);
  }
}
