import 'package:equatable/equatable.dart';

/// Status of the candidate's application for a job.
enum ApplicationStatus {
  applied('APPLIED', 'Applied'),
  underReview('UNDER_REVIEW', 'Under review'),
  shortlisted('SHORTLISTED', 'Shortlisted'),
  rejected('REJECTED', 'Not selected'),
  selected('SELECTED', 'Selected'),
  withdrawn('WITHDRAWN', 'Withdrawn'),
  unknown('', 'Applied');

  const ApplicationStatus(this.apiValue, this.label);

  final String apiValue;

  /// Short text for the Apply button.
  final String label;

  static ApplicationStatus fromApi(String value) => values.firstWhere(
    (s) => s.apiValue == value.toUpperCase(),
    orElse: () => unknown,
  );
}

/// One entry of `POST applications/me/statuses`.
class JobApplicationStatus extends Equatable {
  const JobApplicationStatus({
    required this.applicationId,
    required this.status,
  });

  final String applicationId;
  final ApplicationStatus status;

  @override
  List<Object?> get props => [applicationId, status];
}
