import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/job_suggestion.dart';
import '../../domain/usecases/get_job_suggestions_usecase.dart';

part 'job_suggestions_event.dart';
part 'job_suggestions_state.dart';

/// Keyword suggestions while the user types. Waits [debounce] after the last
/// keystroke, and only the newest request may update the state, so a slow
/// older reply never replaces a newer one.
class JobSuggestionsBloc
    extends Bloc<JobSuggestionsEvent, JobSuggestionsState> {
  JobSuggestionsBloc(
    this._getSuggestions, {
    this.debounce = const Duration(milliseconds: 300),
  }) : super(const JobSuggestionsState()) {
    on<JobSuggestionsQueryChanged>(_onQueryChanged);
    on<JobSuggestionsCleared>(_onCleared);
  }

  final GetJobSuggestionsUseCase _getSuggestions;
  final Duration debounce;

  /// Bumped on every event; a handler whose number is no longer the latest
  /// stops without emitting.
  int _latest = 0;

  Future<void> _onQueryChanged(
    JobSuggestionsQueryChanged event,
    Emitter<JobSuggestionsState> emit,
  ) async {
    final id = ++_latest;
    final query = event.query.trim();

    if (query.length < GetJobSuggestionsUseCase.minLength) {
      emit(const JobSuggestionsState());
      return;
    }

    await Future<void>.delayed(debounce);
    if (id != _latest) return;

    // Keep the previous rows on screen while the new ones load.
    emit(
      JobSuggestionsState(
        status: JobSuggestionsStatus.loading,
        query: state.query,
        suggestions: state.suggestions,
      ),
    );

    final result = await _getSuggestions(query);
    if (id != _latest) return;

    result.fold(
      (items) => emit(
        JobSuggestionsState(
          status: JobSuggestionsStatus.success,
          query: query,
          suggestions: items,
        ),
      ),
      (failure) => emit(
        JobSuggestionsState(
          status: JobSuggestionsStatus.failure,
          query: query,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  void _onCleared(
    JobSuggestionsCleared event,
    Emitter<JobSuggestionsState> emit,
  ) {
    _latest++;
    emit(const JobSuggestionsState());
  }
}
