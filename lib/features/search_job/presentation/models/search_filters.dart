import 'package:equatable/equatable.dart';

import '../../../dashboard/presentation/models/job_filters.dart';
import '../../domain/entities/search_query.dart';

/// Filter-sheet choices on the search screen, and how they map to the
/// [SearchQuery] fields sent to `api/v1/jobs`.
class SearchFilters extends Equatable {
  const SearchFilters({
    this.jobTypes = const {},
    this.experience,
    this.datePosted,
  });

  /// Reads back the filters a query was built with, so reopening search
  /// (from results or a recent search) shows them selected.
  factory SearchFilters.fromQuery(SearchQuery query, {DateTime? now}) {
    final types = (query.employmentType ?? '')
        .split(',')
        .map((v) => _jobTypeByCode[v.trim().toUpperCase()])
        .whereType<JobType>()
        .toSet();

    final experience = ExperienceLevel.values
        .where(
          (e) =>
              _experienceRange(e).$1 == query.experienceMin &&
              _experienceRange(e).$2 == query.experienceMax,
        )
        .firstOrNull;

    return SearchFilters(
      jobTypes: types,
      experience: experience,
      datePosted: _datePostedFrom(query.postedFrom, now ?? DateTime.now()),
    );
  }

  final Set<JobType> jobTypes;
  final ExperienceLevel? experience;
  final DatePosted? datePosted;

  /// How many filter groups are set, for the app bar badge.
  int get count =>
      (jobTypes.isEmpty ? 0 : 1) +
      (experience == null ? 0 : 1) +
      (datePosted == null ? 0 : 1);

  bool get isEmpty => count == 0;

  /// Writes these filters into [query], replacing any it already had.
  /// Several job types are sent comma-separated, e.g. `FULL_TIME,CONTRACT`.
  SearchQuery applyTo(SearchQuery query, {DateTime? now}) {
    final range = experience == null ? null : _experienceRange(experience!);
    final days = datePosted == null ? null : _daysOf(datePosted!);
    final since = days == null
        ? null
        : (now ?? DateTime.now()).toUtc().subtract(Duration(days: days));

    return query.withFilters(
      employmentType: jobTypes.isEmpty
          ? null
          : JobType.values.where(jobTypes.contains).map(_codeOf).join(','),
      experienceMin: range?.$1,
      experienceMax: range?.$2,
      postedFrom: since?.toIso8601String(),
    );
  }

  static String _codeOf(JobType type) => switch (type) {
    JobType.fullTime => 'FULL_TIME',
    JobType.partTime => 'PART_TIME',
    JobType.contract => 'CONTRACT',
    JobType.temporary => 'TEMPORARY',
    JobType.internship => 'INTERNSHIP',
    JobType.freelance => 'FREELANCE',
  };

  static final _jobTypeByCode = {for (final t in JobType.values) _codeOf(t): t};

  /// Years of experience as (min, max); null max means no upper limit.
  static (int, int?) _experienceRange(ExperienceLevel level) => switch (level) {
    ExperienceLevel.fresher => (0, 1),
    ExperienceLevel.oneToThree => (1, 3),
    ExperienceLevel.threeToFive => (3, 5),
    ExperienceLevel.fivePlus => (5, null),
  };

  static int _daysOf(DatePosted value) => switch (value) {
    DatePosted.last24Hours => 1,
    DatePosted.last3Days => 3,
    DatePosted.last7Days => 7,
    DatePosted.last14Days => 14,
  };

  /// The option whose window best matches a saved `postedFrom` date.
  static DatePosted? _datePostedFrom(String? iso, DateTime now) {
    final from = iso == null ? null : DateTime.tryParse(iso);
    if (from == null) return null;
    final days = now.difference(from).inHours / 24;
    DatePosted? best;
    var bestGap = double.infinity;
    for (final option in DatePosted.values) {
      final gap = (_daysOf(option) - days).abs();
      if (gap < bestGap) {
        best = option;
        bestGap = gap;
      }
    }
    return best;
  }

  SearchFilters copyWith({
    Set<JobType>? jobTypes,
    ExperienceLevel? Function()? experience,
    DatePosted? Function()? datePosted,
  }) => SearchFilters(
    jobTypes: jobTypes ?? this.jobTypes,
    experience: experience != null ? experience() : this.experience,
    datePosted: datePosted != null ? datePosted() : this.datePosted,
  );

  @override
  List<Object?> get props => [jobTypes, experience, datePosted];
}
