part of 'job_alerts_bloc.dart';

enum JobAlertsStatus { loading, ready, failure }

enum SaveStatus { idle, saving, success, failure }

class JobAlertsState extends Equatable {
  const JobAlertsState({
    this.status = JobAlertsStatus.loading,
    this.saved,
    this.draft,
    this.categories = const [],
    this.specializationsByCategory = const {},
    this.loadingSpecializations = false,
    this.saveStatus = SaveStatus.idle,
    this.failure,
  });

  final JobAlertsStatus status;

  /// Last version the server has.
  final JobAlertPreferences? saved;

  /// What's on screen, including unsaved edits.
  final JobAlertPreferences? draft;

  /// Every category, to show names for the saved ids and to pick from.
  final List<Category> categories;

  /// Specializations of each chosen category, by category id.
  final Map<String, List<Specialization>> specializationsByCategory;
  final bool loadingSpecializations;
  final SaveStatus saveStatus;
  final Failure? failure;

  bool get hasChanges => draft != null && draft != saved;
  bool get isSaving => saveStatus == SaveStatus.saving;

  /// Chosen categories in list order, skipping unknown ids.
  List<Category> get selectedCategories {
    final ids = draft?.categoryIds ?? const [];
    return [
      for (final c in categories)
        if (ids.contains(c.id)) c,
    ];
  }

  /// Specializations of the chosen categories, for picking.
  List<Specialization> get availableSpecializations => [
    for (final id in draft?.categoryIds ?? const <String>[])
      ...?specializationsByCategory[id],
  ];

  /// Chosen specializations whose names are known.
  List<Specialization> get selectedSpecializations {
    final ids = draft?.specializationIds ?? const [];
    final seen = <String>{};
    return [
      for (final s in availableSpecializations)
        if (ids.contains(s.id) && seen.add(s.id)) s,
    ];
  }

  JobAlertsState copyWith({
    JobAlertPreferences? saved,
    JobAlertPreferences? draft,
    Map<String, List<Specialization>>? specializationsByCategory,
    bool? loadingSpecializations,
    SaveStatus? saveStatus,
    Failure? failure,
  }) {
    return JobAlertsState(
      status: status,
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      categories: categories,
      specializationsByCategory:
          specializationsByCategory ?? this.specializationsByCategory,
      loadingSpecializations:
          loadingSpecializations ?? this.loadingSpecializations,
      saveStatus: saveStatus ?? this.saveStatus,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    saved,
    draft,
    categories,
    specializationsByCategory,
    loadingSpecializations,
    saveStatus,
    failure,
  ];
}
