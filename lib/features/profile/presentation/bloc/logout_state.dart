part of 'logout_bloc.dart';

enum LogoutStatus { initial, loading, success, failure }

class LogoutState extends Equatable {
  final LogoutStatus status;
  final String? errorMessage;

  const LogoutState({this.status = LogoutStatus.initial, this.errorMessage});

  bool get isLoading => status == LogoutStatus.loading;

  @override
  List<Object?> get props => [status, errorMessage];
}
