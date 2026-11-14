part of 'search_location_suggestions_bloc.dart';

sealed class SearchLocationSuggestionsEvent extends Equatable {
  const SearchLocationSuggestionsEvent();

  @override
  List<Object?> get props => [];
}

/// The location text changed. Fetches after a short pause in typing.
final class SearchLocationQueryChanged extends SearchLocationSuggestionsEvent {
  const SearchLocationQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Drop the current suggestions and ignore any request still in flight.
final class SearchLocationSuggestionsCleared
    extends SearchLocationSuggestionsEvent {
  const SearchLocationSuggestionsCleared();
}
