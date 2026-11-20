import '../../../../core/result/result.dart';
import '../entities/job_alert_preferences.dart';
import '../repositories/job_alerts_repository.dart';

/// Saves the candidate's job alert settings and returns what the server kept.
class SaveJobAlertPreferencesUseCase {
  final JobAlertsRepository _repository;

  const SaveJobAlertPreferencesUseCase(this._repository);

  Future<Result<JobAlertPreferences>> call(JobAlertPreferences preferences) =>
      _repository.savePreferences(preferences);
}
