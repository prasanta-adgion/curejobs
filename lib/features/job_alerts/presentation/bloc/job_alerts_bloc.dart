import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/result.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import '../../../specialization/domain/entities/specialization.dart';
import '../../../specialization/domain/usecases/get_specializations_usecase.dart';
import '../../domain/entities/job_alert_preferences.dart';
import '../../domain/usecases/get_job_alert_preferences_usecase.dart';
import '../../domain/usecases/save_job_alert_preferences_usecase.dart';

part 'job_alerts_event.dart';
part 'job_alerts_state.dart';

/// Loads the job alert settings with the category list (the API only sends
/// ids), loads specializations for each chosen category, keeps the edited
/// copy and saves it.
class JobAlertsBloc extends Bloc<JobAlertsEvent, JobAlertsState> {
  final GetJobAlertPreferencesUseCase _getPreferences;
  final SaveJobAlertPreferencesUseCase _savePreferences;
  final GetCategoriesUseCase _getCategories;
  final GetSpecializationsUseCase _getSpecializations;

  JobAlertsBloc(
    this._getPreferences,
    this._savePreferences,
    this._getCategories,
    this._getSpecializations,
  ) : super(const JobAlertsState()) {
    on<JobAlertsRequested>(_onRequested);
    on<JobAlertsChanged>(_onChanged);
    on<JobAlertsCategoriesChanged>(_onCategoriesChanged);
    on<JobAlertsSaveRequested>(_onSave);
  }

  Future<void> _onRequested(
    JobAlertsRequested event,
    Emitter<JobAlertsState> emit,
  ) async {
    emit(const JobAlertsState());

    final results = await (_getPreferences(), _getCategories()).wait;
    final (prefsResult, categoriesResult) = results;

    final Failure? failure = switch ((prefsResult, categoriesResult)) {
      (Err(:final failure), _) => failure,
      (_, Err(:final failure)) => failure,
      _ => null,
    };
    if (failure != null) {
      emit(JobAlertsState(status: JobAlertsStatus.failure, failure: failure));
      return;
    }

    final prefs = (prefsResult as Ok<JobAlertPreferences>).value;
    final categories = (categoriesResult as Ok<List<Category>>).value;
    emit(
      JobAlertsState(
        status: JobAlertsStatus.ready,
        saved: prefs,
        draft: prefs,
        categories: categories,
      ),
    );
    await _loadSpecializations(prefs.categoryIds, emit);
  }

  void _onChanged(JobAlertsChanged event, Emitter<JobAlertsState> emit) {
    emit(state.copyWith(draft: event.draft, saveStatus: SaveStatus.idle));
  }

  Future<void> _onCategoriesChanged(
    JobAlertsCategoriesChanged event,
    Emitter<JobAlertsState> emit,
  ) async {
    final draft = state.draft;
    if (draft == null) return;
    final ids = event.categoryIds;

    // Drop specializations that belonged to a removed category.
    final removed = draft.categoryIds.where((id) => !ids.contains(id));
    final dropped = {
      for (final id in removed)
        for (final s in state.specializationsByCategory[id] ?? const []) s.id,
    };

    emit(
      state.copyWith(
        draft: draft.copyWith(
          categoryIds: ids,
          specializationIds: draft.specializationIds
              .where((id) => !dropped.contains(id))
              .toList(),
        ),
        saveStatus: SaveStatus.idle,
      ),
    );
    await _loadSpecializations(ids, emit);
  }

  /// Loads specializations for categories not loaded yet, in parallel.
  Future<void> _loadSpecializations(
    List<String> categoryIds,
    Emitter<JobAlertsState> emit,
  ) async {
    final missing = categoryIds
        .where((id) => !state.specializationsByCategory.containsKey(id))
        .toList();
    if (missing.isEmpty) return;

    emit(state.copyWith(loadingSpecializations: true));
    final results = await Future.wait([
      for (final id in missing) _getSpecializations(categoryId: id),
    ]);
    final loaded = {...state.specializationsByCategory};
    for (var i = 0; i < missing.length; i++) {
      // A failed category is simply left out; it's retried next time.
      if (results[i] case Ok(:final value)) loaded[missing[i]] = value;
    }
    emit(
      state.copyWith(
        specializationsByCategory: loaded,
        loadingSpecializations: false,
      ),
    );
  }

  Future<void> _onSave(
    JobAlertsSaveRequested event,
    Emitter<JobAlertsState> emit,
  ) async {
    final draft = state.draft;
    if (draft == null || state.saveStatus == SaveStatus.saving) return;

    emit(state.copyWith(saveStatus: SaveStatus.saving));
    final result = await _savePreferences(draft);
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            saved: value,
            draft: value,
            saveStatus: SaveStatus.success,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(saveStatus: SaveStatus.failure, failure: failure));
    }
  }
}
