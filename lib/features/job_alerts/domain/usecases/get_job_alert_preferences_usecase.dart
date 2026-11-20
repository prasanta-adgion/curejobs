import '../../../../core/result/result.dart';
import '../entities/job_alert_preferences.dart';
import '../repositories/job_alerts_repository.dart';

/// Loads the candidate's job alert settings.
class GetJobAlertPreferencesUseCase {
  final JobAlertsRepository _repository;

  const GetJobAlertPreferencesUseCase(this._repository);

  Future<Result<JobAlertPreferences>> call() => _repository.getPreferences();
}
