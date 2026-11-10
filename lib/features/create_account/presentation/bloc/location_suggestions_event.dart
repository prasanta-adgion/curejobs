part of 'location_suggestions_bloc.dart';

sealed class LocationSuggestionsEvent extends Equatable {
  const LocationSuggestionsEvent();

  @override
  List<Object?> get props => [];
}

/// Field was tapped: load suggestions for [query] right away.
final class LocationSuggestionsRequested extends LocationSuggestionsEvent {
  final String query;

  const LocationSuggestionsRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// User typed: load suggestions for [query] after the debounce delay.
final class LocationQueryChanged extends LocationSuggestionsEvent {
  final String query;

  const LocationQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Field lost focus or a suggestion was picked: hide the dropdown.
final class LocationSuggestionsCleared extends LocationSuggestionsEvent {
  const LocationSuggestionsCleared();
}
