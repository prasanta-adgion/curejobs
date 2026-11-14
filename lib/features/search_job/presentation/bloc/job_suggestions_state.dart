part of 'job_suggestions_bloc.dart';

enum JobSuggestionsStatus { initial, loading, success, failure }

final class JobSuggestionsState extends Equatable {
  const JobSuggestionsState({
    this.status = JobSuggestionsStatus.initial,
    this.query = '',
    this.suggestions = const [],
    this.errorMessage,
  });

  final JobSuggestionsStatus status;

  /// Text the current [suggestions] belong to.
  final String query;
  final List<JobSuggestion> suggestions;
  final String? errorMessage;

  bool get isLoading => status == JobSuggestionsStatus.loading;
  bool get hasError => status == JobSuggestionsStatus.failure;

  @override
  List<Object?> get props => [status, query, suggestions, errorMessage];
}
