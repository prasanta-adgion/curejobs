import '../../../../core/utils/json_parser.dart';
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
    final items = JsonParser.list(root['data']);
    final pagination = JsonParser.map(root['pagination']);

    final jobs = [
      for (final item in items)
        if (item is Map<String, dynamic>) JobModel.fromJson(item),
    ];
    final page = JsonParser.integer(pagination['page'], fallback: 1);
    final totalPages = JsonParser.nullableInteger(pagination['totalPages']);

    return JobPageModel(
      jobs: jobs,
      page: page,
      total: JsonParser.integer(pagination['total'], fallback: jobs.length),
      hasMore: JsonParser.boolean(
        pagination['hasMore'],
        fallback: totalPages != null && page < totalPages,
      ),
    );
  }
}
