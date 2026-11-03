part of 'logout_bloc.dart';

sealed class LogoutEvent extends Equatable {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

/// The user confirmed the log out dialog.
final class LogoutRequested extends LogoutEvent {
  const LogoutRequested();
}
