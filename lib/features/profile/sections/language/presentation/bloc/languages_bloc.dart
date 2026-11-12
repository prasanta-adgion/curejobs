import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/language.dart';
import '../../domain/usecases/add_language_usecase.dart';
import '../../domain/usecases/delete_language_usecase.dart';
import '../../domain/usecases/get_languages_usecase.dart';
import '../../domain/usecases/update_language_usecase.dart';

part 'languages_event.dart';
part 'languages_state.dart';

/// Loads the candidate's languages and adds, updates or removes one at a
/// time.
class LanguagesBloc extends Bloc<LanguagesEvent, LanguagesState> {
  final GetLanguagesUseCase _getLanguages;
  final AddLanguageUseCase _addLanguage;
  final UpdateLanguageUseCase _updateLanguage;
  final DeleteLanguageUseCase _deleteLanguage;

  LanguagesBloc({
    required GetLanguagesUseCase getLanguages,
    required AddLanguageUseCase addLanguage,
    required UpdateLanguageUseCase updateLanguage,
    required DeleteLanguageUseCase deleteLanguage,
  }) : _getLanguages = getLanguages,
       _addLanguage = addLanguage,
       _updateLanguage = updateLanguage,
       _deleteLanguage = deleteLanguage,
       super(const LanguagesState()) {
    on<LanguagesRequested>(_onRequested);
    on<LanguageAdded>(_onAdded);
    on<LanguageUpdated>(_onUpdated);
    on<LanguageDeleted>(_onDeleted);
  }

  Future<void> _onRequested(
    LanguagesRequested event,
    Emitter<LanguagesState> emit,
  ) async {
    if (state.status == LanguagesStatus.loading) return;
    emit(state.copyWith(status: LanguagesStatus.loading));
    await _load(emit);
  }

  Future<void> _load(Emitter<LanguagesState> emit, {LanguageChange? change}) {
    return _getLanguages().then(
      (result) => result.fold(
        (items) => emit(
          state.copyWith(
            status: LanguagesStatus.success,
            items: items,
            change: change,
          ),
        ),
        (failure) => emit(
          state.copyWith(status: LanguagesStatus.failure, failure: failure),
        ),
      ),
    );
  }

  /// Adds, then reloads so the new row has its id.
  Future<void> _onAdded(
    LanguageAdded event,
    Emitter<LanguagesState> emit,
  ) async {
    if (state.isAdding) return;
    emit(state.copyWith(isAdding: true));

    final result = await _addLanguage(
      name: event.name,
      proficiency: event.proficiency,
    );
    final failure = result.failureOrNull;
    if (failure != null) {
      emit(state.copyWith(isAdding: false, actionFailure: failure));
      return;
    }
    emit(state.copyWith(isAdding: false));
    await _load(emit, change: LanguageChange.added);
  }

  /// Shows the new level right away and puts the old one back on failure.
  Future<void> _onUpdated(
    LanguageUpdated event,
    Emitter<LanguagesState> emit,
  ) async {
    final language = event.language;
    if (state.isBusy(language) || language.proficiency == event.proficiency) {
      return;
    }

    emit(
      state.copyWith(
        items: _replace(language.copyWith(proficiency: event.proficiency)),
        busyIds: {...state.busyIds, language.id},
      ),
    );

    final result = await _updateLanguage(
      id: language.id,
      proficiency: event.proficiency,
    );
    final remaining = {...state.busyIds}..remove(language.id);

    result.fold(
      (_) => emit(
        state.copyWith(busyIds: remaining, change: LanguageChange.updated),
      ),
      (failure) => emit(
        state.copyWith(
          items: _replace(language),
          busyIds: remaining,
          actionFailure: failure,
        ),
      ),
    );
  }

  /// Keeps the row with a spinner until the server confirms.
  Future<void> _onDeleted(
    LanguageDeleted event,
    Emitter<LanguagesState> emit,
  ) async {
    final language = event.language;
    if (state.isBusy(language)) return;
    emit(state.copyWith(busyIds: {...state.busyIds, language.id}));

    final result = await _deleteLanguage(language.id);
    final remaining = {...state.busyIds}..remove(language.id);

    result.fold(
      (_) => emit(
        state.copyWith(
          items: [...state.items]..removeWhere((l) => l.id == language.id),
          busyIds: remaining,
          change: LanguageChange.removed,
        ),
      ),
      (failure) =>
          emit(state.copyWith(busyIds: remaining, actionFailure: failure)),
    );
  }

  List<Language> _replace(Language updated) => [
    for (final l in state.items) l.id == updated.id ? updated : l,
  ];
}
