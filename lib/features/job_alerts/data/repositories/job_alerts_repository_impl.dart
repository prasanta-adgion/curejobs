import '../../../../core/result/result.dart';
import '../../domain/entities/job_alert_preferences.dart';
import '../../domain/repositories/job_alerts_repository.dart';
import '../datasources/job_alerts_remote_data_source.dart';

class JobAlertsRepositoryImpl implements JobAlertsRepository {
  final JobAlertsRemoteDataSource _remote;

  const JobAlertsRepositoryImpl(this._remote);

  @override
  Future<Result<JobAlertPreferences>> getPreferences() {
    return Result.guard(_remote.getPreferences);
  }

  @override
  Future<Result<JobAlertPreferences>> savePreferences(
    JobAlertPreferences preferences,
  ) {
    return Result.guard(() => _remote.savePreferences(preferences));
  }
}
