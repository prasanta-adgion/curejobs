import 'package:equatable/equatable.dart';

/// Job types an alert can be limited to.
enum AlertEmploymentType {
  fullTime('FULL_TIME', 'Full time'),
  partTime('PART_TIME', 'Part time'),
  contract('CONTRACT', 'Contract'),
  temporary('TEMPORARY', 'Temporary'),
  internship('INTERNSHIP', 'Internship'),
  freelance('FREELANCE', 'Freelance');

  const AlertEmploymentType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AlertEmploymentType? fromApi(String? value) {
    for (final type in values) {
      if (type.apiValue == value?.toUpperCase()) return type;
    }
    return null;
  }
}

/// A city (with or without its state), or a whole state when [city] is null.
class AlertLocation extends Equatable {
  const AlertLocation({this.city, this.state});

  final String? city;
  final String? state;

  bool get isWholeState => city == null && state != null;

  /// "Kolkata, West Bengal", "Uluberia" or "All of West Bengal".
  String get label {
    if (isWholeState) return 'All of $state';
    return [city, state].whereType<String>().join(', ');
  }

  /// Same place regardless of letter case.
  bool sameAs(AlertLocation other) =>
      city?.toLowerCase() == other.city?.toLowerCase() &&
      state?.toLowerCase() == other.state?.toLowerCase();

  @override
  List<Object?> get props => [city, state];
}

/// The candidate's job alert settings: what to match and how to notify.
class JobAlertPreferences extends Equatable {
  const JobAlertPreferences({
    this.enabled = true,
    this.inAppEnabled = true,
    this.emailEnabled = true,
    this.categoryIds = const [],
    this.specializationIds = const [],
    this.locations = const [],
    this.employmentTypes = const [],
    this.experienceMinMonths,
    this.experienceMaxMonths,
    this.salaryMinMinor,
    this.salaryMaxMinor,
    this.salaryCurrency = 'INR',
    this.updatedAt,
  });

  static const maxLocations = 20;

  final bool enabled;
  final bool inAppEnabled;
  final bool emailEnabled;
  final List<String> categoryIds;
  final List<String> specializationIds;
  final List<AlertLocation> locations;
  final List<AlertEmploymentType> employmentTypes;
  final int? experienceMinMonths;
  final int? experienceMaxMonths;

  /// Amounts in the smallest unit (paise for INR).
  final int? salaryMinMinor;
  final int? salaryMaxMinor;
  final String salaryCurrency;
  final DateTime? updatedAt;

  /// How many of the five filter groups have something set.
  int get filtersSet => [
    categoryIds.isNotEmpty || specializationIds.isNotEmpty,
    locations.isNotEmpty,
    employmentTypes.isNotEmpty,
    experienceMinMonths != null || experienceMaxMonths != null,
    salaryMinMinor != null || salaryMaxMinor != null,
  ].where((set) => set).length;

  static const _unset = Object();

  /// Pass `null` to clear a nullable number.
  JobAlertPreferences copyWith({
    bool? enabled,
    bool? inAppEnabled,
    bool? emailEnabled,
    List<String>? categoryIds,
    List<String>? specializationIds,
    List<AlertLocation>? locations,
    List<AlertEmploymentType>? employmentTypes,
    Object? experienceMinMonths = _unset,
    Object? experienceMaxMonths = _unset,
    Object? salaryMinMinor = _unset,
    Object? salaryMaxMinor = _unset,
  }) {
    return JobAlertPreferences(
      enabled: enabled ?? this.enabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      categoryIds: categoryIds ?? this.categoryIds,
      specializationIds: specializationIds ?? this.specializationIds,
      locations: locations ?? this.locations,
      employmentTypes: employmentTypes ?? this.employmentTypes,
      experienceMinMonths: identical(experienceMinMonths, _unset)
          ? this.experienceMinMonths
          : experienceMinMonths as int?,
      experienceMaxMonths: identical(experienceMaxMonths, _unset)
          ? this.experienceMaxMonths
          : experienceMaxMonths as int?,
      salaryMinMinor: identical(salaryMinMinor, _unset)
          ? this.salaryMinMinor
          : salaryMinMinor as int?,
      salaryMaxMinor: identical(salaryMaxMinor, _unset)
          ? this.salaryMaxMinor
          : salaryMaxMinor as int?,
      salaryCurrency: salaryCurrency,
      updatedAt: updatedAt,
    );
  }

  /// Compared to know whether there are unsaved changes; ignores [updatedAt].
  @override
  List<Object?> get props => [
    enabled,
    inAppEnabled,
    emailEnabled,
    categoryIds,
    specializationIds,
    locations,
    employmentTypes,
    experienceMinMonths,
    experienceMaxMonths,
    salaryMinMinor,
    salaryMaxMinor,
    salaryCurrency,
  ];
}
