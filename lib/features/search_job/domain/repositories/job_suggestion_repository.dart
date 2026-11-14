import '../../../../core/result/result.dart';
import '../entities/job_suggestion.dart';

abstract interface class JobSuggestionRepository {
  Future<Result<List<JobSuggestion>>> getSuggestions(String query);
}
