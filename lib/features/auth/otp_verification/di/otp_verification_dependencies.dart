import 'package:get_it/get_it.dart';

import '../../../../core/network/api_client.dart';
import '../data/datasources/email_verification_remote_data_source.dart';
import '../data/repositories/email_verification_repository_impl.dart';
import '../domain/repositories/email_verification_repository.dart';
import '../../login/domain/usecases/login_usecase.dart';
import '../domain/usecases/resend_verification_code_usecase.dart';
import '../domain/usecases/verify_email_and_sign_in_usecase.dart';
import '../domain/usecases/verify_email_usecase.dart';
import '../presentation/bloc/otp_verification_bloc.dart';

void registerOtpVerificationDependencies(GetIt sl) {
  sl.registerLazySingleton<EmailVerificationRemoteDataSource>(
    () => EmailVerificationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<EmailVerificationRepository>(
    () => EmailVerificationRepositoryImpl(
      sl<EmailVerificationRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(sl<EmailVerificationRepository>()),
  );

  sl.registerLazySingleton<ResendVerificationCodeUseCase>(
    () => ResendVerificationCodeUseCase(sl<EmailVerificationRepository>()),
  );

  // Relies on LoginUseCase from the login feature.
  sl.registerLazySingleton<VerifyEmailAndSignInUseCase>(
    () => VerifyEmailAndSignInUseCase(
      sl<VerifyEmailUseCase>(),
      sl<LoginUseCase>(),
    ),
  );

  // New bloc per screen: param1 is the email, param2 the password used to
  // sign in once verified.
  sl.registerFactoryParam<OtpVerificationBloc, String, String>(
    (email, password) => OtpVerificationBloc(
      sl<VerifyEmailAndSignInUseCase>(),
      sl<ResendVerificationCodeUseCase>(),
      email: email,
      password: password,
    ),
  );
}
