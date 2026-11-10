import 'package:equatable/equatable.dart';

/// One degree or course in the candidate's education history.
class Education extends Equatable {
  final String id;
  final String degree;
  final String institution;
  final String? fieldOfStudy;
  final int? startYear;
  final int? completionYear;
  final bool currentlyStudying;
  final String? description;
  final int sortOrder;

  const Education({
    required this.id,
    required this.degree,
    required this.institution,
    this.fieldOfStudy,
    this.startYear,
    this.completionYear,
    this.currentlyStudying = false,
    this.description,
    this.sortOrder = 0,
  });

  /// e.g. "2021 – 2024", "2021 – Present", or "" when no years are known.
  String get period {
    final end = currentlyStudying ? 'Present' : completionYear?.toString();
    final start = startYear?.toString();
    if (start != null && end != null) return '$start – $end';
    return start ?? end ?? '';
  }

  @override
  List<Object?> get props => [
    id,
    degree,
    institution,
    fieldOfStudy,
    startYear,
    completionYear,
    currentlyStudying,
    description,
    sortOrder,
  ];
}
