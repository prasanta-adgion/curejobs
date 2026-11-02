import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _login;

  LoginCubit(this._login) : super(const LoginState());

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) return;
    emit(const LoginState(status: LoginStatus.loading));

    final result = await _login(email: email, password: password);
    if (isClosed) return;

    result.fold(
      (user) => emit(LoginState(status: LoginStatus.success, user: user)),
      (failure) => emit(_fromFailure(failure)),
    );
  }

  /// Clears server errors once the user edits the form.
  void clearErrors() {
    if (state.status == LoginStatus.failure) emit(const LoginState());
  }

  LoginState _fromFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => LoginState(
        status: LoginStatus.failure,
        emailError: failure.errorFor('email'),
        passwordError: failure.errorFor('password'),
        errorMessage: failure.fieldErrors.isEmpty ? failure.message : null,
      ),
      UnauthorizedFailure() => const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Incorrect email or password. Try again.',
      ),
      _ => LoginState(
        status: LoginStatus.failure,
        errorMessage: failure.message,
      ),
    };
  }
}
