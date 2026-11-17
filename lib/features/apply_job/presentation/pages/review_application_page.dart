import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../all_jobs/presentation/formatters/job_formatter.dart';
import '../../../media_preview/presentation/pages/file_viewer_page.dart';
import '../../../profile/presentation/bloc/candidate_profile_bloc.dart';
import '../../../profile/sections/resume/domain/entities/resume.dart';
import '../../domain/entities/application_eligibility.dart';
import '../bloc/submit_application_bloc.dart';
import 'application_sent_page.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<CandidateProfileBloc>()
                ..add(const CandidateProfileRequested()),
        ),
        BlocProvider(create: (_) => sl<SubmitApplicationBloc>()),
      ],
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
  /// Whether "I confirm these details are correct" is ticked.
  final _confirmed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _confirmed.dispose();
    super.dispose();
  }

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

  void _submit() => context.read<SubmitApplicationBloc>().add(
    SubmitApplicationRequested(
      jobId: p.job.id,
      resumeId: p.resume.id,
      answers: p.answers,
    ),
  );

  /// On success, shows the "Application sent" page in place of the flow.
  void _onSubmitState(BuildContext context, SubmitApplicationState state) {
    if (state.status == SubmitStatus.failure) {
      AppSnackbar.error(
        title: "Couldn't send application",
        message: state.failure?.message,
      );
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      ApplicationSentPage.route(p.job, sentAt: DateTime.now()),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = ApplyFlowColors.appBar(context);

    return BlocListener<SubmitApplicationBloc, SubmitApplicationState>(
      listenWhen: (prev, curr) =>
          curr.status == SubmitStatus.success ||
          curr.status == SubmitStatus.failure,
      listener: _onSubmitState,
      child: Scaffold(
        backgroundColor: ApplyFlowColors.page(context),
        appBar: const ApplyStepAppBar(
          title: 'Review application',
          subtitle: 'Check everything before you send',
          step: ApplyStep.review,
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            ApplySection(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Almost done! You're applying for",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _JobSummary(job: p.job),
                ],
              ),
            ),
            _ReviewCard(
              icon: Icons.description_outlined,
              title: 'CV',
              action: 'Change',
              onAction: _changeCv,
              child: _CvRow(resume: p.resume),
            ),
            _ReadySection(
              title: 'Your details',
              action: 'Edit profile',
              onAction: _editProfile,
              child: const _DetailsBody(),
            ),
            if (p.eligibility.questions.isNotEmpty)
              _ReadySection(
                title: 'Screening answers',
                action: 'Edit',
                onAction: _editAnswers,
                child: _AnswersBody(
                  questions: p.eligibility.questions,
                  answers: p.answers,
                ),
              ),
            if (p.eligibility.warnings.isNotEmpty) ...[
              const ApplySectionGap(),
              _WarningNote(eligibility: p.eligibility),
            ],
            const ApplySectionGap(),
            const _AfterSend(),
          ],
        ),
        bottomNavigationBar: ApplyBottomBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Whole box is tappable so the checkbox is easy to hit.
              Material(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _confirmed.value = !_confirmed.value,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _confirmed,
                            builder: (context, confirmed, _) => Checkbox(
                              value: confirmed,
                              activeColor: accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              onChanged: (v) => _confirmed.value = v ?? false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I confirm these details are correct',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SubmitApplicationBloc, SubmitApplicationState>(
                builder: (context, submit) => ValueListenableBuilder<bool>(
                  valueListenable: _confirmed,
                  builder: (context, confirmed, _) => ApplyPrimaryButton(
                    label: submit.isSending ? 'Sending…' : 'Send application',
                    icon: Icons.send_rounded,
                    onPressed: confirmed && !submit.isSending ? _submit : null,
                  ),
                ),
              ),
            ],
          ),
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
      if (job.city case final c? when c.trim().isNotEmpty) c,
      JobFormatter.employmentType(job.employmentType),
    ].join(' · ');

    final accent = ApplyFlowColors.appBar(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ApplyFlowColors.section(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _initials,
              style: theme.textTheme.titleMedium?.copyWith(
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
                Text(job.organization.name, style: theme.textTheme.bodySmall),
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
      ),
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

/// A gap, then a full-width section with a green "ready" tick, the title
/// and an action link on the right.
class _ReadySection extends StatelessWidget {
  const _ReadySection({
    required this.title,
    required this.action,
    required this.onAction,
    required this.child,
  });

  final String title;
  final String action;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = StatusTone.of(context, CheckStatus.pass);
    return Column(
      children: [
        const ApplySectionGap(),
        ApplySection(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: tone.background,
                    child: Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: tone.foreground,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: ApplyFlowColors.appBar(context),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(action),
                  ),
                ],
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

/// "After you send": what happens next, so sending doesn't feel final and
/// unknown.
class _AfterSend extends StatelessWidget {
  const _AfterSend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = ApplyFlowColors.appBar(context);
    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
    return ApplySection(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'After you send',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          line(
            Icons.mail_outline_rounded,
            'The recruiter gets your CV, profile and answers',
          ),
          line(
            Icons.send_outlined,
            'Track the status anytime in the Applied tab',
          ),
        ],
      ),
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
        final initials = c.fullName
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
        final accent = ApplyFlowColors.appBar(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initials,
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
                          c.fullName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (c.professionalTitle case final t?
                            when t.trim().isNotEmpty)
                          Text(t, style: muted),
                        if (c.location case final l?)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Expanded(child: Text(l, style: muted)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'The recruiter sees your full profile with this application.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    'Q${i + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: ApplyFlowColors.appBar(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
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
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _answerFor(questions[i]) == null
                              ? scheme.onSurfaceVariant
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Amber strip: "You meet 4 of 6 requirements. The recruiter will check
/// skills and location. You can still send."
class _WarningNote extends StatelessWidget {
  const _WarningNote({required this.eligibility});

  final ApplicationEligibility eligibility;

  String get _text {
    final e = eligibility;
    final total = e.passed.length + e.warnings.length + e.failed.length;
    final names = e.warnings
        .map((w) => checkTitle(w.code).toLowerCase())
        .toSet()
        .toList();
    final list = names.length <= 1
        ? names.join()
        : '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
    return 'You meet ${e.passed.length} of $total requirements. '
        'The recruiter will check $list. You can still send.';
  }

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.of(context, CheckStatus.warning);
    final color = StatusTone.text(context, CheckStatus.warning);
    return ApplySection(
      color: tone.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
