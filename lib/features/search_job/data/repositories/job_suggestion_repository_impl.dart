import '../../../../core/result/result.dart';
import '../../domain/entities/job_suggestion.dart';
import '../../domain/repositories/job_suggestion_repository.dart';
import '../datasources/job_suggestion_remote_data_source.dart';

class JobSuggestionRepositoryImpl implements JobSuggestionRepository {
  JobSuggestionRepositoryImpl(this._remote);

  final JobSuggestionRemoteDataSource _remote;

  /// Recent answers by lower-cased query, so backspacing shows results
  /// instantly. The oldest entry is dropped first.
  final _cache = <String, List<JobSuggestion>>{};
  static const _cacheSize = 20;

  @override
  Future<Result<List<JobSuggestion>>> getSuggestions(String query) async {
    final text = query.trim();
    final key = text.toLowerCase();
    final cached = _cache[key];
    if (cached != null) return Result.ok(cached);

    final result = await Result.guard(() => _remote.getSuggestions(text));
    return result.map((items) {
      final cleaned = _dedupe(items);
      _cache[key] = cleaned;
      if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
      return cleaned;
    });
  }

  /// One suggestion per text (ignoring case), keeping the higher-priority
  /// type, in the API's ranking order. E.g. "Nursing" (category) is kept
  /// and "nursing" (title) is dropped.
  static List<JobSuggestion> _dedupe(List<JobSuggestion> items) {
    final best = <String, JobSuggestion>{};
    for (final item in items) {
      final key = item.value.toLowerCase();
      final current = best[key];
      if (current == null || item.type.index < current.type.index) {
        best[key] = item;
      }
    }
    final seen = <String>{};
    return [
      for (final item in items)
        if (seen.add(item.value.toLowerCase())) best[item.value.toLowerCase()]!,
    ];
  }
}
