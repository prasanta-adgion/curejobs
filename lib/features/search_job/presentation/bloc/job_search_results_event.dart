part of 'job_search_results_bloc.dart';

sealed class JobSearchResultsEvent extends Equatable {
  const JobSearchResultsEvent();

  @override
  List<Object?> get props => [];
}

/// Starts a search from page 1 (also used for retry and refresh).
final class JobSearchRequested extends JobSearchResultsEvent {
  const JobSearchRequested(this.query);

  final SearchQuery query;

  @override
  List<Object?> get props => [query];
}

/// Loads the next page of the current search.
final class JobSearchNextPageRequested extends JobSearchResultsEvent {
  const JobSearchNextPageRequested();
}
