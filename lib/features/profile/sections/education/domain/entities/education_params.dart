import 'package:equatable/equatable.dart';

/// What the candidate enters when adding or editing education.
class EducationParams extends Equatable {
  final String degree;
  final String institution;
  final String fieldOfStudy;
  final int? startYear;
  final int? completionYear;
  final bool currentlyStudying;
  final String description;

  const EducationParams({
    this.degree = '',
    this.institution = '',
    this.fieldOfStudy = '',
    this.startYear,
    this.completionYear,
    this.currentlyStudying = false,
    this.description = '',
  });

  @override
  List<Object?> get props => [
    degree,
    institution,
    fieldOfStudy,
    startYear,
    completionYear,
    currentlyStudying,
    description,
  ];
}
