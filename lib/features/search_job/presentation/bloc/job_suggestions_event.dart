part of 'job_suggestions_bloc.dart';

sealed class JobSuggestionsEvent extends Equatable {
  const JobSuggestionsEvent();

  @override
  List<Object?> get props => [];
}

/// The keyword text changed. Fetches after a short pause in typing.
final class JobSuggestionsQueryChanged extends JobSuggestionsEvent {
  const JobSuggestionsQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Drop the current suggestions and ignore any request still in flight.
final class JobSuggestionsCleared extends JobSuggestionsEvent {
  const JobSuggestionsCleared();
}
