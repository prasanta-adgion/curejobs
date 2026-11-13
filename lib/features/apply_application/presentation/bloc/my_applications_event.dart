part of 'my_applications_bloc.dart';

sealed class MyApplicationsEvent extends Equatable {
  const MyApplicationsEvent();

  @override
  List<Object?> get props => [];
}

/// First load, showing the full-screen loader.
final class MyApplicationsRequested extends MyApplicationsEvent {
  const MyApplicationsRequested();
}

/// Pull to refresh; keeps the current list visible.
final class MyApplicationsRefreshed extends MyApplicationsEvent {
  const MyApplicationsRefreshed();
}

/// Scrolled near the end of the list.
final class MyApplicationsNextPageRequested extends MyApplicationsEvent {
  const MyApplicationsNextPageRequested();
}

/// Null means "All".
final class MyApplicationsFilterChanged extends MyApplicationsEvent {
  const MyApplicationsFilterChanged(this.status);

  final ApplicationStatus? status;

  @override
  List<Object?> get props => [status];
}

/// User confirmed withdrawing [application].
final class MyApplicationWithdrawRequested extends MyApplicationsEvent {
  const MyApplicationWithdrawRequested(this.application);

  final JobApplication application;

  @override
  List<Object?> get props => [application.id];
}
