import '../../../../../core/result/result.dart';
import '../entities/auth_user.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class AuthRepository {
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  });

  /// Ends the session on the server and always clears it on this device, so
  /// the user is signed out even if the server can't be reached.
  Future<Result<void>> logout();
}
