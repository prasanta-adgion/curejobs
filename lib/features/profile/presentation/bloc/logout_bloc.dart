import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/login/domain/usecases/logout_usecase.dart';

part 'logout_event.dart';
part 'logout_state.dart';

/// Signs the candidate out from the profile screen.
class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUseCase _logout;

  LogoutBloc(this._logout) : super(const LogoutState()) {
    on<LogoutRequested>(_onRequested);
  }

  Future<void> _onRequested(
    LogoutRequested event,
    Emitter<LogoutState> emit,
  ) async {
    if (state.isLoading || state.status == LogoutStatus.success) return;
    emit(const LogoutState(status: LogoutStatus.loading));

    final result = await _logout();

    result.fold(
      (_) => emit(const LogoutState(status: LogoutStatus.success)),
      (failure) => emit(
        LogoutState(
          status: LogoutStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
