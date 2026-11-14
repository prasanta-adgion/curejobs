import 'package:equatable/equatable.dart';

/// What a suggestion refers to. The order is the priority used when two
/// suggestions have the same text (a category beats a plain title).
enum JobSuggestionType { category, specialization, title, unknown }

/// One keyword suggestion from `GET api/v1/jobs/suggestions`.
class JobSuggestion extends Equatable {
  const JobSuggestion({
    required this.id,
    required this.value,
    this.type = JobSuggestionType.unknown,
    this.hint,
    this.jobCount,
    this.categoryId,
    this.specializationId,
  });

  final String id;

  /// Text that goes into the keyword field, e.g. "Burns Nursing".
  final String value;
  final JobSuggestionType type;

  /// Parent name, e.g. "Nursing" for a specialization.
  final String? hint;
  final int? jobCount;
  final String? categoryId;
  final String? specializationId;

  @override
  List<Object?> get props => [
    id,
    value,
    type,
    hint,
    jobCount,
    categoryId,
    specializationId,
  ];
}
