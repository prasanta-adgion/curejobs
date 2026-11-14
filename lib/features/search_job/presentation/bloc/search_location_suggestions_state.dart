part of 'search_location_suggestions_bloc.dart';

enum SearchLocationSuggestionsStatus { initial, loading, success, failure }

final class SearchLocationSuggestionsState extends Equatable {
  const SearchLocationSuggestionsState({
    this.status = SearchLocationSuggestionsStatus.initial,
    this.query = '',
    this.suggestions = const [],
    this.errorMessage,
  });

  final SearchLocationSuggestionsStatus status;

  /// Text the current [suggestions] belong to.
  final String query;

  /// Cities first, then areas, then states.
  final List<LocationSuggestion> suggestions;

  /// Set only when every type failed to load.
  final String? errorMessage;

  bool get isLoading => status == SearchLocationSuggestionsStatus.loading;
  bool get hasError => status == SearchLocationSuggestionsStatus.failure;

  @override
  List<Object?> get props => [status, query, suggestions, errorMessage];
}
