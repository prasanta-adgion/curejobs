import '../../../../core/result/result.dart';
import '../entities/job_alert_preferences.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class JobAlertsRepository {
  Future<Result<JobAlertPreferences>> getPreferences();

  Future<Result<JobAlertPreferences>> savePreferences(
    JobAlertPreferences preferences,
  );
}
