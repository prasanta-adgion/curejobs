import 'package:equatable/equatable.dart';

import 'employment_type.dart';

/// What the candidate enters when adding or editing a position.
class ExperienceParams extends Equatable {
  final String jobTitle;
  final String organizationName;
  final EmploymentType? employmentType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool currentlyWorking;
  final String location;
  final String responsibilities;

  const ExperienceParams({
    this.jobTitle = '',
    this.organizationName = '',
    this.employmentType,
    this.startDate,
    this.endDate,
    this.currentlyWorking = false,
    this.location = '',
    this.responsibilities = '',
  });

  @override
  List<Object?> get props => [
    jobTitle,
    organizationName,
    employmentType,
    startDate,
    endDate,
    currentlyWorking,
    location,
    responsibilities,
  ];
}
