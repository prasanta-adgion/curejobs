import 'package:equatable/equatable.dart';

/// Application statuses returned by the API.
enum ApplicationStatus {
  applied('APPLIED', 'Applied'),
  underReview('UNDER_REVIEW', 'Under review'),
  shortlisted('SHORTLISTED', 'Shortlisted'),
  selected('SELECTED', 'Selected'),
  rejected('REJECTED', 'Rejected'),
  withdrawn('WITHDRAWN', 'Withdrawn');

  const ApplicationStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ApplicationStatus fromApi(String value) => values.firstWhere(
    (s) => s.apiValue == value,
    orElse: () => ApplicationStatus.applied,
  );

  /// Still in progress, so the user can withdraw.
  bool get isActive =>
      this == applied || this == underReview || this == shortlisted;

  /// Steps done out of 4 (Applied → Review → Shortlist → Result).
  /// 0 hides the progress bar.
  int get progressStep => switch (this) {
    applied => 1,
    underReview => 2,
    shortlisted => 3,
    selected || rejected => 4,
    withdrawn => 0,
  };
}

class JobApplication extends Equatable {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobSlug,
    required this.jobTitle,
    required this.city,
    this.state,
    this.country,
    required this.status,
    required this.appliedAt,
    this.withdrawnAt,
    required this.isJobOpen,
  });

  final String id;
  final String jobId;
  final String jobSlug;
  final String jobTitle;
  final String city;
  final String? state;
  final String? country;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? withdrawnAt;

  /// The job is still published (not expired or closed).
  final bool isJobOpen;

  /// "Kolkata, West Bengal", capitalising the city and skipping a null state.
  String get location {
    final c = city.trim();
    final cityText = c.isEmpty ? c : '${c[0].toUpperCase()}${c.substring(1)}';
    return [
      if (cityText.isNotEmpty) cityText,
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
    ].join(', ');
  }

  @override
  List<Object?> get props => [id, status, withdrawnAt, isJobOpen];
}

/// One page of applications plus server-side totals per status.
class ApplicationsPage extends Equatable {
  const ApplicationsPage({
    required this.items,
    required this.page,
    required this.total,
    required this.hasMore,
    required this.counts,
  });

  final List<JobApplication> items;
  final int page;
  final int total;
  final bool hasMore;
  final Map<ApplicationStatus, int> counts;

  @override
  List<Object?> get props => [items, page, total, hasMore, counts];
}
