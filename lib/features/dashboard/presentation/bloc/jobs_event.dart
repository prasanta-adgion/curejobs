part of 'jobs_bloc.dart';

sealed class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the first page, or reload it (pull to refresh, retry).
final class JobsRequested extends JobsEvent {
  const JobsRequested();
}

/// Append the next page when the user nears the end of the list.
final class JobsNextPageRequested extends JobsEvent {
  const JobsNextPageRequested();
}
