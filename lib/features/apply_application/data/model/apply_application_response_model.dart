import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/job_application.dart';

/// Parses `GET api/v1/applications/me`:
/// `{ data: [...], pagination: {...}, counts: {...} }`.
class ApplicationsPageModel extends ApplicationsPage {
  const ApplicationsPageModel({
    required super.items,
    required super.page,
    required super.total,
    required super.hasMore,
    required super.counts,
  });

  static ApplicationsPageModel fromJson(Object? json) {
    final root = JsonParser.map(json);
    final pagination = JsonParser.map(root['pagination']);
    final countsJson = JsonParser.map(root['counts']);

    final items = [
      for (final item in JsonParser.list(root['data']))
        if (item is Map<String, dynamic>) JobApplicationModel.fromJson(item),
    ];

    return ApplicationsPageModel(
      items: items,
      page: JsonParser.integer(pagination['page'], fallback: 1),
      total: JsonParser.integer(pagination['total'], fallback: items.length),
      hasMore: JsonParser.boolean(pagination['hasMore']),
      counts: {
        for (final s in ApplicationStatus.values)
          s: JsonParser.integer(countsJson[s.apiValue]),
      },
    );
  }
}

class JobApplicationModel extends JobApplication {
  const JobApplicationModel({
    required super.id,
    required super.jobId,
    required super.jobSlug,
    required super.jobTitle,
    required super.city,
    super.state,
    super.country,
    required super.status,
    required super.appliedAt,
    super.withdrawnAt,
    required super.isJobOpen,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    final job = JsonParser.map(json['job']);
    return JobApplicationModel(
      id: JsonParser.string(json['id']),
      jobId: JsonParser.string(json['jobId']),
      jobSlug: JsonParser.string(job['slug']),
      jobTitle: JsonParser.string(job['title'], fallback: 'Untitled job'),
      city: JsonParser.string(job['city']),
      state: JsonParser.nullableString(job['state']),
      country: JsonParser.nullableString(job['country']),
      status: ApplicationStatus.fromApi(JsonParser.string(json['status'])),
      appliedAt:
          (JsonParser.dateTime(json['appliedAt']) ??
                  JsonParser.dateTime(json['createdAt']) ??
                  DateTime.now())
              .toLocal(),
      withdrawnAt: JsonParser.dateTime(json['withdrawnAt'])?.toLocal(),
      isJobOpen: JsonParser.string(job['status']) == 'PUBLISHED',
    );
  }
}
