import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/location_suggestion.dart';
import '../../domain/enums/location_type.dart';
import '../../domain/usecases/get_location_suggestions_usecase.dart';

part 'location_suggestions_event.dart';
part 'location_suggestions_state.dart';

/// Suggestions for one location field of a fixed [type].
///
/// Typing is debounced, and any newer event cancels the one in flight, so a
/// late response for old input never overwrites the current list.
class LocationSuggestionsBloc
    extends Bloc<LocationSuggestionsEvent, LocationSuggestionsState> {
  LocationSuggestionsBloc(
    this._getSuggestions, {
    required this.type,
    this.debounce = const Duration(milliseconds: 400),
  }) : super(const LocationSuggestionsState()) {
    on<LocationSuggestionsEvent>(_onEvent, transformer: _debounceRestartable);
  }

  final GetLocationSuggestionsUseCase _getSuggestions;
  final LocationType type;
  final Duration debounce;

  Future<void> _onEvent(
    LocationSuggestionsEvent event,
    Emitter<LocationSuggestionsState> emit,
  ) async {
    switch (event) {
      case LocationSuggestionsCleared():
        emit(const LocationSuggestionsState());
      case LocationSuggestionsRequested(:final query):
      case LocationQueryChanged(:final query):
        await _load(query, emit);
    }
  }

  Future<void> _load(
    String query,
    Emitter<LocationSuggestionsState> emit,
  ) async {
    emit(
      LocationSuggestionsState(
        status: LocationSuggestionsStatus.loading,
        suggestions: state.suggestions,
      ),
    );

    final result = await _getSuggestions(type: type, query: query);

    emit(switch (result) {
      Ok(:final value) => LocationSuggestionsState(
        status: LocationSuggestionsStatus.success,
        suggestions: value,
      ),
      Err(:final failure) => LocationSuggestionsState(
        status: LocationSuggestionsStatus.failure,
        failure: failure,
      ),
    });
  }

  /// Delays [LocationQueryChanged] by [debounce]; every new event cancels
  /// the previous one (pending delay or in-flight request).
  Stream<LocationSuggestionsEvent> Function(
    Stream<LocationSuggestionsEvent>,
    EventMapper<LocationSuggestionsEvent>,
  )
  get _debounceRestartable => (events, mapper) {
    return _switchMap(events, (event) {
      if (event is! LocationQueryChanged) return mapper(event);
      return Stream<void>.fromFuture(Future<void>.delayed(debounce))
          .asyncExpand((_) => mapper(event));
    });
  };
}

/// Maps each event to a stream, cancelling the previous one.
Stream<T> _switchMap<T>(Stream<T> source, Stream<T> Function(T) mapper) {
  late final StreamController<T> controller;
  StreamSubscription<T>? outer;
  StreamSubscription<T>? inner;
  var outerDone = false;

  controller = StreamController<T>(
    onListen: () {
      outer = source.listen(
        (event) {
          inner?.cancel();
          inner = mapper(event).listen(
            controller.add,
            onError: controller.addError,
            onDone: () {
              inner = null;
              if (outerDone) controller.close();
            },
          );
        },
        onError: controller.addError,
        onDone: () {
          outerDone = true;
          if (inner == null) controller.close();
        },
      );
    },
    onCancel: () async {
      await inner?.cancel();
      await outer?.cancel();
    },
  );

  return controller.stream;
}
