part of 'location_suggestions_bloc.dart';

enum LocationSuggestionsStatus { initial, loading, success, failure }

class LocationSuggestionsState extends Equatable {
  final LocationSuggestionsStatus status;
  final List<LocationSuggestion> suggestions;

  /// Set when loading fails.
  final Failure? failure;

  const LocationSuggestionsState({
    this.status = LocationSuggestionsStatus.initial,
    this.suggestions = const [],
    this.failure,
  });

  bool get isLoading => status == LocationSuggestionsStatus.loading;

  /// Whether the dropdown has anything to show.
  bool get hasContent =>
      isLoading ||
      status == LocationSuggestionsStatus.failure ||
      (status == LocationSuggestionsStatus.success && suggestions.isNotEmpty);

  @override
  List<Object?> get props => [status, suggestions, failure];
}
