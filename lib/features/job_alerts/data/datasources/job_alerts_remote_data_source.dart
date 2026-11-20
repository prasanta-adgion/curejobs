import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/job_alert_preferences.dart';
import '../models/job_alert_preferences_model.dart';

abstract interface class JobAlertsRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<JobAlertPreferences> getPreferences();

  /// Throws a `Failure` on error (see [ApiClient]).
  Future<JobAlertPreferences> savePreferences(JobAlertPreferences preferences);
}

class JobAlertsRemoteDataSourceImpl implements JobAlertsRemoteDataSource {
  final ApiClient _client;

  const JobAlertsRemoteDataSourceImpl(this._client);

  @override
  Future<JobAlertPreferences> getPreferences() {
    return _client.get<JobAlertPreferences>(
      ApiEndpoints.jobAlertPreferences,
      decoder: JobAlertPreferencesModel.fromJson,
    );
  }

  @override
  Future<JobAlertPreferences> savePreferences(JobAlertPreferences preferences) {
    return _client.put<JobAlertPreferences>(
      ApiEndpoints.jobAlertPreferences,
      body: JobAlertPreferencesModel.toJson(preferences),
      decoder: JobAlertPreferencesModel.fromJson,
    );
  }
}
