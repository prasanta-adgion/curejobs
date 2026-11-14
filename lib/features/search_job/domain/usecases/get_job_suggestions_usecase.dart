import '../../../../core/result/result.dart';
import '../entities/job_suggestion.dart';
import '../repositories/job_suggestion_repository.dart';

/// Keyword suggestions (categories, specializations, job titles) for [query].
class GetJobSuggestionsUseCase {
  const GetJobSuggestionsUseCase(this._repository);

  /// Shorter text returns no suggestions without calling the API.
  static const minLength = 2;

  final JobSuggestionRepository _repository;

  Future<Result<List<JobSuggestion>>> call(String query) {
    final text = query.trim();
    if (text.length < minLength) return Future.value(const Result.ok([]));
    return _repository.getSuggestions(text);
  }
}
