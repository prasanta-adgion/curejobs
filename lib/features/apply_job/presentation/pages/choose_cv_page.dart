import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../media_preview/presentation/pages/file_viewer_page.dart';
import '../../../profile/sections/resume/domain/entities/resume.dart';
import '../../../profile/sections/resume/presentation/bloc/resume_bloc.dart';
import '../../domain/entities/application_eligibility.dart';
import '../widgets/apply_flow_widgets.dart';
import 'review_application_page.dart';

/// Step 3 of applying: pick one of the saved CVs (or upload a new one).
class ChooseCvPage extends StatelessWidget {
  const ChooseCvPage({
    super.key,
    required this.job,
    required this.eligibility,
    this.answers = const [],
  });

  final Job job;
  final ApplicationEligibility eligibility;
  final List<ScreeningAnswer> answers;

  static Route<void> route(
    Job job, {
    required ApplicationEligibility eligibility,
    List<ScreeningAnswer> answers = const [],
  }) => MaterialPageRoute(
    builder: (_) =>
        ChooseCvPage(job: job, eligibility: eligibility, answers: answers),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ResumeBloc>()..add(const ResumesRequested()),
      child: _ChooseCvView(page: this),
    );
  }
}

class _ChooseCvView extends StatefulWidget {
  const _ChooseCvView({required this.page});

  final ChooseCvPage page;

  @override
  State<_ChooseCvView> createState() => _ChooseCvViewState();
}

class _ChooseCvViewState extends State<_ChooseCvView> {
  String? _selectedId;

  ChooseCvPage get p => widget.page;

  /// The default CV (first in [ResumeState.sorted]) unless the user picked.
  Resume? _selected(List<Resume> resumes) {
    if (resumes.isEmpty) return null;
    return resumes.firstWhere(
      (r) => r.id == _selectedId,
      orElse: () => resumes.first,
    );
  }

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  // TODO: wire to the resume upload API once it exists.
  void _upload() => _snack('Upload CV coming soon');

  void _preview(Resume r) {
    if (!r.hasFile) {
      _snack("This CV's file isn't ready yet");
      return;
    }
    Navigator.of(context).push(
      FileViewerPage.route(
        fileId: r.generatedFileId!,
        title: r.title.isEmpty ? 'My CV' : r.title,
      ),
    );
  }

  void _continue(Resume resume) {
    Navigator.of(context).push(
      ReviewApplicationPage.route(
        job: p.job,
        eligibility: p.eligibility,
        answers: p.answers,
        resume: resume,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ApplyFlowColors.page(context),
      appBar: ApplyStepAppBar(
        title: 'Choose your CV',
        subtitle: p.job.title,
        step: ApplyStep.cv,
      ),
      body: BlocBuilder<ResumeBloc, ResumeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ResumeStatus.failure) {
            return _LoadError(
              message: state.failure?.message ?? 'Something went wrong.',
              onRetry: () =>
                  context.read<ResumeBloc>().add(const ResumesRequested()),
            );
          }

          final resumes = state.sorted;
          final selected = _selected(resumes);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    _InfoSection(withAnswers: p.answers.isNotEmpty),
                    const ApplySectionGap(),
                    if (resumes.isEmpty)
                      ApplySection(child: _EmptyCvs(onUpload: _upload))
                    else ...[
                      ApplySection(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Column(
                          children: [
                            ApplySectionHeader(
                              icon: Icons.folder_copy_outlined,
                              title: 'Your CVs',
                              trailing: Text(
                                '${resumes.length}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                            for (final r in resumes) ...[
                              const ApplyRowDivider(),
                              _CvRow(
                                resume: r,
                                selected: r.id == selected?.id,
                                onTap: () => setState(() => _selectedId = r.id),
                              ),
                            ],
                            if (selected != null && selected.hasFile) ...[
                              const ApplyRowDivider(),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => _preview(selected),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Preview selected CV'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const ApplySectionGap(),
                      _UploadRow(onTap: _upload),
                    ],
                  ],
                ),
              ),
              ApplyBottomBar(
                child: ApplyPrimaryButton(
                  label: 'Continue to review',
                  onPressed: selected == null
                      ? null
                      : () => _continue(selected),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.withAnswers});

  final bool withAnswers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ApplySection(
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The recruiter will see this CV with your profile'
              '${withAnswers ? ' and answers' : ''}.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One selectable CV row: file badge, title, meta line and radio.
class _CvRow extends StatelessWidget {
  const _CvRow({
    required this.resume,
    required this.selected,
    required this.onTap,
  });

  final Resume resume;
  final bool selected;
  final VoidCallback onTap;

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

  String get _meta {
    final kind = resume.isUploaded ? 'Uploaded' : 'Built in app';
    final d = resume.updatedAt ?? resume.createdAt;
    if (d == null) return kind;
    final l = d.toLocal();
    return '$kind · ${l.day} ${_months[l.month - 1]} ${l.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = ApplyFlowColors.appBar(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const _FileBadge(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          resume.title.isEmpty ? 'My CV' : resume.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (resume.isDefault) ...[
                        const SizedBox(width: 6),
                        const _DefaultTag(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _meta,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? accent : scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _FileBadge extends StatelessWidget {
  const _FileBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'PDF',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: scheme.error, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DefaultTag extends StatelessWidget {
  const _DefaultTag();

  @override
  Widget build(BuildContext context) {
    final accent = ApplyFlowColors.appBar(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Default',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: accent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Full-width tappable "Upload a new CV" row.
class _UploadRow extends StatelessWidget {
  const _UploadRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = ApplyFlowColors.appBar(context);
    return Material(
      color: ApplyFlowColors.section(context),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.cloud_upload_outlined, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload a new CV',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'PDF or DOCX, up to 5 MB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCvs extends StatelessWidget {
  const _EmptyCvs({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 36,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your CV to apply',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "It's saved to your profile for next time.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_rounded, size: 18),
            label: const Text('Upload CV'),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
