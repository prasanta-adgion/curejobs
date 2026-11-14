import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../create_account/domain/entities/location_suggestion.dart';
import '../../../create_account/domain/enums/location_type.dart';
import '../../../create_account/domain/usecases/get_location_suggestions_usecase.dart';

part 'search_location_suggestions_event.dart';
part 'search_location_suggestions_state.dart';

/// Location suggestions for job search. For each query it calls the
/// location API once per type in [types] (AREA, CITY, STATE) with the same
/// `q`, all at the same time, and merges the answers into one list.
///
/// Waits [debounce] after the last keystroke, and only the newest request
/// may update the state, so a slow older reply never replaces a newer one.
class SearchLocationSuggestionsBloc
    extends
        Bloc<SearchLocationSuggestionsEvent, SearchLocationSuggestionsState> {
  SearchLocationSuggestionsBloc(
    this._getSuggestions, {
    this.debounce = const Duration(milliseconds: 300),
  }) : super(const SearchLocationSuggestionsState()) {
    on<SearchLocationQueryChanged>(_onQueryChanged);
    on<SearchLocationSuggestionsCleared>(_onCleared);
  }

  final GetLocationSuggestionsUseCase _getSuggestions;
  final Duration debounce;

  /// Types requested for every query, in the order they are shown: a city
  /// is the most common pick, then an area inside a city, then a state.
  static const types = [
    LocationType.city,
    LocationType.area,
    LocationType.state,
  ];

  /// Text shorter than this returns no suggestions without calling the API.
  static const minLength = 2;

  /// Bumped on every event; a handler whose number is no longer the latest
  /// stops without emitting.
  int _latest = 0;

  Future<void> _onQueryChanged(
    SearchLocationQueryChanged event,
    Emitter<SearchLocationSuggestionsState> emit,
  ) async {
    final id = ++_latest;
    final query = event.query.trim();

    if (query.length < minLength) {
      emit(const SearchLocationSuggestionsState());
      return;
    }

    await Future<void>.delayed(debounce);
    if (id != _latest) return;

    // Keep the previous rows on screen while the new ones load.
    emit(
      SearchLocationSuggestionsState(
        status: SearchLocationSuggestionsStatus.loading,
        query: state.query,
        suggestions: state.suggestions,
      ),
    );

    // One call per type, same q, in parallel.
    final results = await Future.wait([
      for (final type in types) _getSuggestions(type: type, query: query),
    ]);
    if (id != _latest) return;

    final merged = <LocationSuggestion>[];
    final seenIds = <String>{};
    String? firstError;
    for (final result in results) {
      switch (result) {
        case Ok(:final value):
          for (final s in value) {
            if (seenIds.add(s.id)) merged.add(s);
          }
        case Err(:final failure):
          firstError ??= failure.message;
      }
    }

    // Show whatever loaded; it's only an error if every type failed.
    final allFailed = results.every((r) => r is Err);
    emit(
      allFailed
          ? SearchLocationSuggestionsState(
              status: SearchLocationSuggestionsStatus.failure,
              query: query,
              errorMessage: firstError,
            )
          : SearchLocationSuggestionsState(
              status: SearchLocationSuggestionsStatus.success,
              query: query,
              suggestions: merged,
            ),
    );
  }

  void _onCleared(
    SearchLocationSuggestionsCleared event,
    Emitter<SearchLocationSuggestionsState> emit,
  ) {
    _latest++;
    emit(const SearchLocationSuggestionsState());
  }
}
