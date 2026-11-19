import 'package:equatable/equatable.dart';

import '../../../all_jobs/domain/entities/job.dart';
import '../../../applied_application/domain/entities/job_application.dart';

export '../../../applied_application/domain/entities/job_application.dart'
    show ApplicationStatus;

/// One application with everything the candidate submitted, from
/// `GET api/v1/applications/me/:id`.
class ApplicationDetail extends Equatable {
  const ApplicationDetail({
    required this.id,
    required this.status,
    required this.appliedAt,
    this.withdrawnAt,
    required this.job,
    this.history = const [],
    this.screening,
    this.answers = const [],
    this.resume,
  });

  final String id;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? withdrawnAt;
  final Job job;

  /// Status changes, oldest first.
  final List<StatusChange> history;
  final ScreeningResult? screening;
  final List<ScreeningAnswer> answers;
  final SubmittedResume? resume;

  @override
  List<Object?> get props => [id, status, withdrawnAt];
}

class StatusChange extends Equatable {
  const StatusChange({required this.status, required this.at});

  final ApplicationStatus status;
  final DateTime at;

  @override
  List<Object?> get props => [status, at];
}

enum CheckStatus { pass, warning, fail }

class ScreeningCheck extends Equatable {
  const ScreeningCheck({required this.status, required this.message});

  final CheckStatus status;
  final String message;

  @override
  List<Object?> get props => [status, message];
}

class ScreeningResult extends Equatable {
  const ScreeningResult({required this.passed, required this.checks});

  final bool passed;
  final List<ScreeningCheck> checks;

  int get metCount => checks.where((c) => c.status == CheckStatus.pass).length;

  @override
  List<Object?> get props => [passed, checks];
}

class ScreeningAnswer extends Equatable {
  const ScreeningAnswer({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  List<Object?> get props => [question, answer];
}

class SubmittedResume extends Equatable {
  const SubmittedResume({
    required this.title,
    this.templateKey,
    this.generatedFileId,
  });

  final String title;
  final String? templateKey;
  final String? generatedFileId;

  @override
  List<Object?> get props => [title, templateKey, generatedFileId];
}
