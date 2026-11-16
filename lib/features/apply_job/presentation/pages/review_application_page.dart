import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../all_jobs/presentation/formatters/job_formatter.dart';
import '../../../media_preview/presentation/pages/file_viewer_page.dart';
import '../../../profile/presentation/bloc/candidate_profile_bloc.dart';
import '../../../profile/sections/resume/domain/entities/resume.dart';
import '../../domain/entities/application_eligibility.dart';
import '../widgets/apply_flow_widgets.dart';
import '../widgets/eligibility_widgets.dart';

/// Final step: everything the recruiter will get, with links to change it.
class ReviewApplicationPage extends StatelessWidget {
  const ReviewApplicationPage({
    super.key,
    required this.job,
    required this.eligibility,
    required this.answers,
    required this.resume,
  });

  final Job job;
  final ApplicationEligibility eligibility;
  final List<ScreeningAnswer> answers;
  final Resume resume;

  static Route<void> route({
    required Job job,
    required ApplicationEligibility eligibility,
    required List<ScreeningAnswer> answers,
    required Resume resume,
  }) => MaterialPageRoute(
    builder: (_) => ReviewApplicationPage(
      job: job,
      eligibility: eligibility,
      answers: answers,
      resume: resume,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CandidateProfileBloc>()..add(const CandidateProfileRequested()),
      child: _ReviewView(page: this),
    );
  }
}

class _ReviewView extends StatefulWidget {
  const _ReviewView({required this.page});

  final ReviewApplicationPage page;

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  bool _confirmed = false;

  ReviewApplicationPage get p => widget.page;

  /// Back to the CV step (the previous route).
  void _changeCv() => Navigator.of(context).pop();

  /// Back to the screening questions: two routes down (review → CV → questions).
  void _editAnswers() {
    var count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  void _editProfile() => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('Edit your profile from the Profile tab')),
    );

  void _submit() {
    // Ready to send: p.job.id, p.resume.id and p.answers.
    // TODO: call the submit-application API, then on success:
    // Navigator.of(context).pushAndRemoveUntil(
    //   ApplicationSentPage.route(p.job), (r) => r.isFirst);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Submit coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warnings = p.eligibility.warnings.length;

    return Scaffold(
      backgroundColor: ApplyFlowColors.page(context),
      appBar: const ApplyStepAppBar(
        title: 'Review application',
        subtitle: 'Check everything before you send',
        step: ApplyStep.review,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          ApplySection(child: _JobSummary(job: p.job)),
          _ReviewCard(
            icon: Icons.description_outlined,
            title: 'CV',
            action: 'Change',
            onAction: _changeCv,
            child: _CvRow(resume: p.resume),
          ),
          _ReviewCard(
            icon: Icons.person_outline_rounded,
            title: 'Your details',
            action: 'Edit profile',
            onAction: _editProfile,
            child: const _DetailsBody(),
          ),
          if (p.eligibility.questions.isNotEmpty)
            _ReviewCard(
              icon: Icons.quiz_outlined,
              title: 'Screening answers (${p.answers.length})',
              action: 'Edit',
              onAction: _editAnswers,
              child: _AnswersBody(
                questions: p.eligibility.questions,
                answers: p.answers,
              ),
            ),
          if (warnings > 0) ...[
            const ApplySectionGap(),
            _WarningNote(count: warnings),
          ],
        ],
      ),
      bottomNavigationBar: ApplyBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _confirmed = !_confirmed),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _confirmed,
                        activeColor: ApplyFlowColors.appBar(context),
                        onChanged: (v) =>
                            setState(() => _confirmed = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'I confirm these details are correct and agree to '
                        'share my profile with this employer.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ApplyPrimaryButton(
              label: 'Submit application',
              icon: Icons.send_rounded,
              onPressed: _confirmed ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobSummary extends StatelessWidget {
  const _JobSummary({required this.job});

  final Job job;

  String get _initials {
    final words = job.organization.name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2);
    return words.map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final meta = [
      job.organization.name,
      if (job.city case final c? when c.trim().isNotEmpty) c,
      JobFormatter.employmentType(job.employmentType),
    ].join(' · ');

    final accent = ApplyFlowColors.appBar(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _initials,
            style: theme.textTheme.titleSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A gap, then a full-width section with a header and an action link.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.action,
    required this.onAction,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String action;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ApplySectionGap(),
        ApplySection(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ApplySectionHeader(
                icon: icon,
                title: title,
                actionLabel: action,
                onAction: onAction,
              ),
              const SizedBox(height: 4),
              Padding(padding: const EdgeInsets.only(right: 8), child: child),
            ],
          ),
        ),
      ],
    );
  }
}

class _CvRow extends StatelessWidget {
  const _CvRow({required this.resume});

  final Resume resume;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final d = (resume.updatedAt ?? resume.createdAt)?.toLocal();
    final title = resume.title.isEmpty ? 'My CV' : resume.title;

    return Row(
      children: [
        Container(
          width: 40,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.errorContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'PDF',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (d != null)
                Text(
                  'Updated ${d.day} ${_months[d.month - 1]} ${d.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (resume.hasFile)
          IconButton(
            tooltip: 'Preview',
            icon: const Icon(Icons.visibility_outlined, size: 20),
            onPressed: () => Navigator.of(context).push(
              FileViewerPage.route(
                fileId: resume.generatedFileId!,
                title: title,
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.5,
    );

    return BlocBuilder<CandidateProfileBloc, CandidateProfileState>(
      builder: (context, state) {
        final c = state.candidate;
        if (c == null) {
          if (state.status == CandidateProfileStatus.failure) {
            return Text("Couldn't load your details.", style: muted);
          }
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.fullName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (c.professionalTitle case final t? when t.trim().isNotEmpty)
              Text(t, style: muted),
            if (c.location case final l?) Text(l, style: muted),
          ],
        );
      },
    );
  }
}

class _AnswersBody extends StatelessWidget {
  const _AnswersBody({required this.questions, required this.answers});

  final List<ScreeningQuestion> questions;
  final List<ScreeningAnswer> answers;

  String? _answerFor(ScreeningQuestion q) {
    final a = answers.where((a) => a.questionId == q.id).firstOrNull;
    if (a == null) return null;
    if (a.optionId != null) {
      return q.options.where((o) => o.id == a.optionId).firstOrNull?.label;
    }
    return a.text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        for (var i = 0; i < questions.length; i++)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: ApplyFlowColors.divider(context)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questions[i].prompt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _answerFor(questions[i]) ?? 'Not answered',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _WarningNote extends StatelessWidget {
  const _WarningNote({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.of(context, CheckStatus.warning);
    return ApplySection(
      color: tone.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: tone.foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The recruiter will review $count '
              '${count == 1 ? 'item' : 'items'}, like skills and location. '
              'You can still apply.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: tone.foreground, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
