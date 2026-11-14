import 'package:equatable/equatable.dart';

/// What the user searched for. Both parts are optional: an empty keyword
/// means "all jobs" and an empty location means "anywhere".
class SearchQuery extends Equatable {
  const SearchQuery({this.keyword = '', this.location = ''});

  final String keyword;
  final String location;

  bool get isEmpty => keyword.trim().isEmpty && location.trim().isEmpty;

  /// Short label for result headers, e.g. "Staff nurse · Bengaluru".
  String get summary {
    final city = location.split(',').first.trim();
    return [
      keyword.trim().isEmpty ? 'All jobs' : keyword.trim(),
      if (city.isNotEmpty) city,
    ].join(' · ');
  }

  /// Same search ignoring case and surrounding spaces.
  bool sameAs(SearchQuery other) =>
      keyword.trim().toLowerCase() == other.keyword.trim().toLowerCase() &&
      location.trim().toLowerCase() == other.location.trim().toLowerCase();

  SearchQuery copyWith({String? keyword, String? location}) => SearchQuery(
    keyword: keyword ?? this.keyword,
    location: location ?? this.location,
  );

  Map<String, String> toJson() => {
    'keyword': keyword.trim(),
    'location': location.trim(),
  };

  factory SearchQuery.fromJson(Map<String, dynamic> json) => SearchQuery(
    keyword: json['keyword'] as String? ?? '',
    location: json['location'] as String? ?? '',
  );

  @override
  List<Object?> get props => [keyword, location];
}
