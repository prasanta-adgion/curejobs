part of 'job_alerts_bloc.dart';

sealed class JobAlertsEvent extends Equatable {
  const JobAlertsEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the settings and the category list.
final class JobAlertsRequested extends JobAlertsEvent {
  const JobAlertsRequested();
}

/// Any edit except categories; [draft] is the whole new copy.
final class JobAlertsChanged extends JobAlertsEvent {
  const JobAlertsChanged(this.draft);

  final JobAlertPreferences draft;

  @override
  List<Object?> get props => [draft];
}

/// New category selection. Loads their specializations and drops chosen
/// specializations of removed categories.
final class JobAlertsCategoriesChanged extends JobAlertsEvent {
  const JobAlertsCategoriesChanged(this.categoryIds);

  final List<String> categoryIds;

  @override
  List<Object?> get props => [categoryIds];
}

final class JobAlertsSaveRequested extends JobAlertsEvent {
  const JobAlertsSaveRequested();
}
