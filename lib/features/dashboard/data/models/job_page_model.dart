import '../../domain/entities/job_page.dart';
import 'job_model.dart';

class JobPageModel extends JobPage {
  const JobPageModel({
    required super.jobs,
    required super.page,
    required super.total,
    required super.hasMore,
  });

  /// Reads `{data: [...], pagination: {page, total, hasMore, ...}}`.
  factory JobPageModel.fromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    final items = root['data'] is List ? root['data'] as List : const [];
    final pagination = root['pagination'] is Map<String, dynamic>
        ? root['pagination'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final jobs = [
      for (final item in items)
        if (item is Map<String, dynamic>) JobModel.fromJson(item),
    ];
    final page = (pagination['page'] as num?)?.toInt() ?? 1;
    final totalPages = (pagination['totalPages'] as num?)?.toInt();

    return JobPageModel(
      jobs: jobs,
      page: page,
      total: (pagination['total'] as num?)?.toInt() ?? jobs.length,
      hasMore:
          pagination['hasMore'] as bool? ??
          (totalPages != null && page < totalPages),
    );
  }
}
