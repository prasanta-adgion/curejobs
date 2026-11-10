import '../../../../../core/result/result.dart';
import '../../domain/repositories/email_verification_repository.dart';
import '../datasources/email_verification_remote_data_source.dart';

class EmailVerificationRepositoryImpl implements EmailVerificationRepository {
  final EmailVerificationRemoteDataSource _remote;

  const EmailVerificationRepositoryImpl(this._remote);

  @override
  Future<Result<void>> verifyEmail({
    required String email,
    required String code,
  }) {
    return Result.guard(() => _remote.verifyEmail(email: email, code: code));
  }

  @override
  Future<Result<void>> resendCode({required String email}) {
    return Result.guard(() => _remote.resendCode(email: email));
  }
}
