import '../../../../core/utils/json_parser.dart';
import '../../../all_jobs/data/models/job_model.dart';
import '../../domain/entities/application_detail.dart';

/// Parses `GET api/v1/applications/me/:id`: `{ data: {...} }`.
class ApplicationDetailModel extends ApplicationDetail {
  const ApplicationDetailModel({
    required super.id,
    required super.status,
    required super.appliedAt,
    super.withdrawnAt,
    required super.job,
    super.history,
    super.screening,
    super.answers,
    super.resume,
  });

  static ApplicationDetailModel fromJson(Object? json) {
    final data = JsonParser.map(JsonParser.map(json)['data']);

    // `jobPosting` has the full job; fall back to the short `job`.
    final posting = JsonParser.map(data['jobPosting']);
    final job = JobModel.fromJson(
      posting.isNotEmpty ? posting : JsonParser.map(data['job']),
    );

    final history = <StatusChange>[
      for (final h in JsonParser.list(data['history']))
        if (h is Map<String, dynamic>)
          if (JsonParser.dateTime(h['createdAt']) case final at?)
            StatusChange(
              status: ApplicationStatus.fromApi(
                JsonParser.string(h['toStatus']),
              ),
              at: at,
            ),
    ]..sort((a, b) => a.at.compareTo(b.at));

    final screeningJson = JsonParser.map(data['screeningSnapshot']);
    final resumeJson = JsonParser.map(data['resumeSnapshot']);

    return ApplicationDetailModel(
      id: JsonParser.string(data['id']),
      status: ApplicationStatus.fromApi(JsonParser.string(data['status'])),
      appliedAt:
          JsonParser.dateTime(data['appliedAt']) ??
          JsonParser.dateTime(data['createdAt']) ??
          DateTime.now(),
      withdrawnAt: JsonParser.dateTime(data['withdrawnAt']),
      job: job,
      history: history,
      screening: screeningJson.isEmpty ? null : _screening(screeningJson),
      answers: _answers(screeningJson),
      resume: resumeJson.isEmpty
          ? null
          : SubmittedResume(
              title: JsonParser.string(resumeJson['title'], fallback: 'Resume'),
              templateKey: JsonParser.nullableString(resumeJson['templateKey']),
              generatedFileId: JsonParser.nullableString(
                resumeJson['generatedFileId'],
              ),
            ),
    );
  }

  static ScreeningResult _screening(Map<String, dynamic> json) {
    return ScreeningResult(
      passed:
          JsonParser.string(json['screeningOutcome']).toUpperCase() == 'PASSED',
      checks: [
        for (final c in JsonParser.list(json['checks']))
          if (c is Map<String, dynamic>)
            ScreeningCheck(
              status: switch (JsonParser.string(c['status']).toUpperCase()) {
                'PASS' => CheckStatus.pass,
                'WARNING' => CheckStatus.warning,
                _ => CheckStatus.fail,
              },
              message: JsonParser.string(c['message']),
            ),
      ],
    );
  }

  static List<ScreeningAnswer> _answers(Map<String, dynamic> json) {
    return [
      for (final a in JsonParser.list(json['answers']))
        if (a is Map<String, dynamic>)
          ScreeningAnswer(
            question: JsonParser.string(a['question']),
            answer:
                JsonParser.nullableString(a['answerText']) ??
                JsonParser.nullableString(a['option']) ??
                '—',
          ),
    ];
  }
}
