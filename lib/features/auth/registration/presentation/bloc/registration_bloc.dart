import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
import '../../domain/entities/registration_result.dart';
import '../../domain/usecases/register_usecase.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegisterUseCase _register;

  RegistrationBloc(this._register) : super(const RegistrationState()) {
    on<RegistrationSubmitted>(_onSubmitted);
    on<RegistrationErrorsCleared>(_onErrorsCleared);
  }

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.isLoading) return;
    emit(const RegistrationState(status: RegistrationStatus.loading));

    final result = await _register(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (value) => emit(
        RegistrationState(
          status: RegistrationStatus.success,
          result: value,
          // Needed to sign in after email verification.
          password: event.password,
        ),
      ),
      (failure) => emit(_fromFailure(failure)),
    );
  }

  void _onErrorsCleared(
    RegistrationErrorsCleared event,
    Emitter<RegistrationState> emit,
  ) {
    if (state.status == RegistrationStatus.failure) {
      emit(const RegistrationState());
    }
  }

  RegistrationState _fromFailure(Failure failure) {
    return switch (failure) {
      ValidationFailure() => RegistrationState(
        status: RegistrationStatus.failure,
        emailError: failure.errorFor('email'),
        passwordError: failure.errorFor('password'),
        errorMessage: failure.fieldErrors.isEmpty ? failure.message : null,
      ),
      // 409 EMAIL_ALREADY_REGISTERED: the server message belongs on the field.
      ConflictFailure() => RegistrationState(
        status: RegistrationStatus.failure,
        emailError: failure.message,
      ),
      _ => RegistrationState(
        status: RegistrationStatus.failure,
        errorMessage: failure.message,
      ),
    };
  }
}
