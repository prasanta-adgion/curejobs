import 'package:equatable/equatable.dart';

/// What the user searched for. [keyword] and [location] are the text shown
/// in the fields; the other fields are exact filters for `api/v1/jobs`,
/// filled from a picked suggestion (or a future filter screen). Anything
/// null or empty is not sent.
class SearchQuery extends Equatable {
  const SearchQuery({
    this.keyword = '',
    this.location = '',
    this.categoryId,
    this.specializationId,
    this.employmentType,
    this.area,
    this.city,
    this.state,
    this.experienceMin,
    this.experienceMax,
    this.salaryMin,
    this.salaryMax,
    this.organizationId,
    this.postedFrom,
    this.sort,
  });

  final String keyword;
  final String location;

  /// Set when a category or specialization suggestion was picked.
  final String? categoryId;
  final String? specializationId;

  /// e.g. `FULL_TIME`.
  final String? employmentType;

  /// Set when a location suggestion was picked.
  final String? area;
  final String? city;
  final String? state;

  final int? experienceMin;
  final int? experienceMax;
  final int? salaryMin;
  final int? salaryMax;
  final String? organizationId;

  /// ISO date string.
  final String? postedFrom;
  final String? sort;

  bool get isEmpty => keyword.trim().isEmpty && location.trim().isEmpty;

  /// True when the location came from a picked suggestion.
  bool get hasPlace => area != null || city != null || state != null;

  /// Short label for result headers, e.g. "Staff nurse · Bengaluru".
  String get summary {
    final place = location.split(',').first.trim();
    return [
      keyword.trim().isEmpty ? 'All jobs' : keyword.trim(),
      if (place.isNotEmpty) place,
    ].join(' · ');
  }

  /// Same search text ignoring case and surrounding spaces.
  bool sameAs(SearchQuery other) =>
      keyword.trim().toLowerCase() == other.keyword.trim().toLowerCase() &&
      location.trim().toLowerCase() == other.location.trim().toLowerCase();

  /// Replaces the keyword and its ids together (null ids clear them).
  SearchQuery withKeyword(
    String keyword, {
    String? categoryId,
    String? specializationId,
  }) => _copy(
    keyword: keyword,
    categoryId: () => categoryId,
    specializationId: () => specializationId,
  );

  /// Replaces the location and its parts together (null parts clear them).
  SearchQuery withLocation(
    String location, {
    String? area,
    String? city,
    String? state,
  }) => _copy(
    location: location,
    area: () => area,
    city: () => city,
    state: () => state,
  );

  SearchQuery _copy({
    String? keyword,
    String? location,
    String? Function()? categoryId,
    String? Function()? specializationId,
    String? Function()? area,
    String? Function()? city,
    String? Function()? state,
  }) => SearchQuery(
    keyword: keyword ?? this.keyword,
    location: location ?? this.location,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    specializationId: specializationId != null
        ? specializationId()
        : this.specializationId,
    employmentType: employmentType,
    area: area != null ? area() : this.area,
    city: city != null ? city() : this.city,
    state: state != null ? state() : this.state,
    experienceMin: experienceMin,
    experienceMax: experienceMax,
    salaryMin: salaryMin,
    salaryMax: salaryMax,
    organizationId: organizationId,
    postedFrom: postedFrom,
    sort: sort,
  );

  /// Query parameters for `api/v1/jobs` (without page and limit).
  ///
  /// `q` is always sent with any category/specialization ids. A picked place
  /// is sent as `area`/`city`/`state` instead of the `location` text, since
  /// a label like "Kolkata, West Bengal" would not match as free text.
  Map<String, Object> toQueryParameters() {
    final q = keyword.trim();
    final place = location.trim();
    return {
      if (q.isNotEmpty) 'q': q,
      if (!hasPlace && place.isNotEmpty) 'location': place,
      'categoryId': ?categoryId,
      'specializationId': ?specializationId,
      'employmentType': ?employmentType,
      'area': ?area,
      'city': ?city,
      'state': ?state,
      'experienceMin': ?experienceMin,
      'experienceMax': ?experienceMax,
      'salaryMin': ?salaryMin,
      'salaryMax': ?salaryMax,
      'organizationId': ?organizationId,
      'postedFrom': ?postedFrom,
      'sort': ?sort,
    };
  }

  /// Text plus every set filter, so a recent search reruns the same way.
  Map<String, Object> toJson() => {
    'keyword': keyword.trim(),
    'location': location.trim(),
    'categoryId': ?categoryId,
    'specializationId': ?specializationId,
    'employmentType': ?employmentType,
    'area': ?area,
    'city': ?city,
    'state': ?state,
    'experienceMin': ?experienceMin,
    'experienceMax': ?experienceMax,
    'salaryMin': ?salaryMin,
    'salaryMax': ?salaryMax,
    'organizationId': ?organizationId,
    'postedFrom': ?postedFrom,
    'sort': ?sort,
  };

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    String? text(String key) => switch (json[key]) {
      final String s when s.isNotEmpty => s,
      _ => null,
    };
    int? number(String key) => switch (json[key]) {
      final num n => n.toInt(),
      _ => null,
    };
    return SearchQuery(
      keyword: text('keyword') ?? '',
      location: text('location') ?? '',
      categoryId: text('categoryId'),
      specializationId: text('specializationId'),
      employmentType: text('employmentType'),
      area: text('area'),
      city: text('city'),
      state: text('state'),
      experienceMin: number('experienceMin'),
      experienceMax: number('experienceMax'),
      salaryMin: number('salaryMin'),
      salaryMax: number('salaryMax'),
      organizationId: text('organizationId'),
      postedFrom: text('postedFrom'),
      sort: text('sort'),
    );
  }

  @override
  List<Object?> get props => [
    keyword,
    location,
    categoryId,
    specializationId,
    employmentType,
    area,
    city,
    state,
    experienceMin,
    experienceMax,
    salaryMin,
    salaryMax,
    organizationId,
    postedFrom,
    sort,
  ];
}
