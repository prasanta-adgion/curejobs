import 'package:equatable/equatable.dart';

/// Overall result of the eligibility check.
enum EligibilityStatus {
  eligible,
  screeningRequired,
  notEligible,
  unknown;

  static EligibilityStatus fromApi(String value) => switch (value) {
    'ELIGIBLE' => eligible,
    'SCREENING_REQUIRED' => screeningRequired,
    'NOT_ELIGIBLE' || 'INELIGIBLE' => notEligible,
    _ => unknown,
  };

  bool get canApply => this == eligible || this == screeningRequired;
}

enum CheckStatus {
  pass,
  warning,
  fail,
  required;

  static CheckStatus fromApi(String value) => switch (value) {
    'PASS' => pass,
    'FAIL' => fail,
    'REQUIRED' => required,
    _ => warning,
  };
}

class EligibilityCheck extends Equatable {
  const EligibilityCheck({
    required this.code,
    required this.status,
    required this.message,
  });

  /// e.g. `SKILLS`, `LOCATION`, `SCREENING`.
  final String code;
  final CheckStatus status;
  final String message;

  static const _missingSkillsPrefix = 'Missing required skills:';

  /// Skills parsed out of a `SKILLS` warning message; empty otherwise.
  List<String> get missingSkills {
    if (code != 'SKILLS' || !message.startsWith(_missingSkillsPrefix)) {
      return const [];
    }
    return message
        .substring(_missingSkillsPrefix.length)
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  List<Object?> get props => [code, status, message];
}

enum QuestionType {
  singleChoice,
  shortAnswer,
  unknown;

  static QuestionType fromApi(String value) => switch (value) {
    'SINGLE_CHOICE' => singleChoice,
    'SHORT_ANSWER' => shortAnswer,
    _ => unknown,
  };
}

class QuestionOption extends Equatable {
  const QuestionOption({required this.id, required this.label});

  final String id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}

class ScreeningQuestion extends Equatable {
  const ScreeningQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.required,
    this.options = const [],
    this.maxAnswerLength,
  });

  final String id;
  final QuestionType type;
  final String prompt;
  final bool required;
  final List<QuestionOption> options;
  final int? maxAnswerLength;

  @override
  List<Object?> get props => [
    id,
    type,
    prompt,
    required,
    options,
    maxAnswerLength,
  ];
}

/// The candidate's answer to one screening question.
class ScreeningAnswer extends Equatable {
  const ScreeningAnswer({required this.questionId, this.optionId, this.text});

  final String questionId;

  /// Set for `SINGLE_CHOICE`.
  final String? optionId;

  /// Set for `SHORT_ANSWER`.
  final String? text;

  @override
  List<Object?> get props => [questionId, optionId, text];
}

class ApplicationEligibility extends Equatable {
  const ApplicationEligibility({
    required this.status,
    this.checks = const [],
    this.questions = const [],
  });

  final EligibilityStatus status;
  final List<EligibilityCheck> checks;
  final List<ScreeningQuestion> questions;

  /// Checks shown in the list; `SCREENING` drives the button instead.
  List<EligibilityCheck> get _listed =>
      checks.where((c) => c.status != CheckStatus.required).toList();

  List<EligibilityCheck> get passed =>
      _listed.where((c) => c.status == CheckStatus.pass).toList();
  List<EligibilityCheck> get warnings =>
      _listed.where((c) => c.status == CheckStatus.warning).toList();
  List<EligibilityCheck> get failed =>
      _listed.where((c) => c.status == CheckStatus.fail).toList();

  bool get hasQuestions => questions.isNotEmpty;

  @override
  List<Object?> get props => [status, checks, questions];
}
