import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/job_application_status.dart';

abstract final class JobApplicationStatusModel {
  /// Parses `{ "data": { "<jobId>": { applicationId, status } } }` into a
  /// map keyed by job id. Jobs not applied to are simply absent.
  static Map<String, JobApplicationStatus> mapFromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;
    return {
      for (final e in data.entries)
        if (e.value is Map)
          e.key: JobApplicationStatus(
            applicationId: JsonParser.string(
              JsonParser.map(e.value)['applicationId'],
            ),
            status: ApplicationStatus.fromApi(
              JsonParser.string(JsonParser.map(e.value)['status']),
            ),
          ),
    };
  }
}
