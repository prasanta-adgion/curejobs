import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/create_account_params.dart';
import '../../domain/usecases/create_account_usecase.dart';

part 'create_account_event.dart';
part 'create_account_state.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  CreateAccountBloc(this._createAccount) : super(const CreateAccountState()) {
    on<CreateAccountSubmitted>(_onSubmitted);
  }

  final CreateAccountUseCase _createAccount;

  Future<void> _onSubmitted(
    CreateAccountSubmitted event,
    Emitter<CreateAccountState> emit,
  ) async {
    if (state.isSubmitting) return;
    emit(
      const CreateAccountState(status: CreateAccountSubmitStatus.submitting),
    );

    final result = await _createAccount(event.params);

    emit(switch (result) {
      Ok() => const CreateAccountState(
        status: CreateAccountSubmitStatus.success,
      ),
      Err(:final failure) => CreateAccountState(
        status: CreateAccountSubmitStatus.failure,
        failure: failure,
      ),
    });
  }
}
