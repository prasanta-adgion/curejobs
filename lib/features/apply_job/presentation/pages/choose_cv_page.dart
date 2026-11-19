import 'package:curejobs/core/constants/asset_paths.dart';
import 'package:curejobs/core/utils/date_time_utils.dart';
import 'package:curejobs/shared/widgets/separation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../media_preview/presentation/pages/file_viewer_page.dart';
import '../../../media_preview/presentation/pick_and_upload_document.dart';
import '../../../profile/sections/resume/domain/entities/resume.dart';
import '../../../profile/sections/resume/presentation/bloc/resume_bloc.dart';
import '../../domain/entities/application_eligibility.dart';
import '../widgets/apply_flow_widgets.dart';
import '../widgets/eligibility_widgets.dart';
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
  /// Id the user tapped (or the CV just uploaded); null means the default.
  final _selectedId = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _selectedId.dispose();
    super.dispose();
  }

  ChooseCvPage get p => widget.page;

  /// The default CV (first in [ResumeState.sorted]) unless the user picked.
  Resume? _selected(List<Resume> resumes) {
    if (resumes.isEmpty) return null;
    return resumes.firstWhere(
      (r) => r.id == _selectedId.value,
      orElse: () => resumes.first,
    );
  }

  void _snack(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  /// File id of a CV just uploaded here; selected once it shows in the list.
  String? _uploadedFileId;

  /// Picks a CV from the device, previews and uploads it, then saves it to
  /// the profile. The new CV is selected when the list reloads.
  Future<void> _uploadCv() async {
    final bloc = context.read<ResumeBloc>();
    if (bloc.state.creating) return;
    final uploaded = await pickAndUploadDocument(context);
    if (uploaded == null || !mounted) return;
    _uploadedFileId = uploaded.fileId;
    bloc.add(
      ResumeUploaded(title: uploaded.file.name, fileId: uploaded.fileId),
    );
  }

  void _onResumeListener(BuildContext context, ResumeState state) {
    final failure = state.createFailure;
    if (failure != null) {
      _uploadedFileId = null;
      AppSnackbar.error(title: "Couldn't save CV", message: failure.message);
      return;
    }
    if (state.created) {
      AppSnackbar.success(title: 'CV uploaded');
      return;
    }
    final fileId = _uploadedFileId;
    if (fileId == null) return;
    for (final r in state.items) {
      if (r.generatedFileId == fileId) {
        _uploadedFileId = null;
        _selectedId.value = r.id;
        return;
      }
    }
  }

  void _preview(Resume r) {
    if (!r.hasFile) {
      _snack("This CV's file isn't ready yet");
      return;
    }
    Navigator.of(context).push(
      FileViewerPage.route(fileId: r.generatedFileId!, title: _cvTitle(r)),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: ApplyFlowColors.page(context),
      appBar: ApplyStepAppBar(
        title: 'Choose your CV',
        subtitle: '${p.job.title} · ${p.job.organization.name}',
        step: ApplyStep.cv,
        hasQuestions: p.eligibility.questions.isNotEmpty,
      ),
      body: BlocConsumer<ResumeBloc, ResumeState>(
        listenWhen: (prev, curr) =>
            curr.created ||
            curr.createFailure != null ||
            prev.items != curr.items,
        listener: _onResumeListener,
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
          if (resumes.isEmpty) {
            return ListView(
              children: [
                _Intro(withAnswers: p.answers.isNotEmpty),
                // const ApplySectionGap(),
                const SectionBand(),

                ApplySection(child: _EmptyCvs(onUpload: _uploadCv)),
              ],
            );
          }

          return ValueListenableBuilder<String?>(
            valueListenable: _selectedId,
            builder: (context, _, _) {
              final selected = _selected(resumes);
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        _Intro(withAnswers: p.answers.isNotEmpty),
                        // const ApplySectionGap(),
                        const SectionBand(),

                        ApplySection(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Your saved CVs',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    '${resumes.length} '
                                    '${resumes.length == 1 ? 'CV' : 'CVs'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              for (final r in resumes) ...[
                                const SizedBox(height: 10),
                                _CvTile(
                                  resume: r,
                                  selected: r.id == selected?.id,
                                  onTap: () => _selectedId.value = r.id,
                                  onPreview: r.hasFile
                                      ? () => _preview(r)
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // const ApplySectionGap(),
                        const SectionBand(),

                        ApplySection(child: _UploadBox(onTap: _uploadCv)),
                      ],
                    ),
                  ),
                  ApplyBottomBar(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected != null) ...[
                          _SendingLine(title: _cvTitle(selected)),
                          const SizedBox(height: 10),
                        ],
                        ApplyPrimaryButton(
                          label: 'Continue to review',
                          // icon: Icons.arrow_forward_rounded,
                          icon: Image.asset(
                            AssetPaths.forwordArrow,
                            width: 18,
                            height: 18,
                            color: Colors.white,
                          ),
                          onPressed: selected == null
                              ? null
                              : () => _continue(selected),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String _cvTitle(Resume r) => r.title.isEmpty ? 'My CV' : r.title;

/// "Which CV should we send?" and who will see it.
class _Intro extends StatelessWidget {
  const _Intro({required this.withAnswers});

  final bool withAnswers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ApplySection(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which CV should we send?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'The recruiter sees this CV along with your profile'
            '${withAnswers ? ' and answers' : ''}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One CV as a rounded, tappable tile. The selected one is highlighted and
/// shows "Preview this CV".
class _CvTile extends StatelessWidget {
  const _CvTile({
    required this.resume,
    required this.selected,
    required this.onTap,
    required this.onPreview,
  });

  final Resume resume;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  String get _meta {
    final kind = resume.isUploaded ? 'Uploaded' : 'Built in app';
    final d = resume.updatedAt ?? resume.createdAt;
    if (d == null) return kind;
    final l = d.toLocal();
    final verb = resume.updatedAt != null ? 'Updated ' : '';
    return '$kind · $verb${l.day} ${DateTimeUtils.months[l.month - 1]} ${l.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = ApplyFlowColors.appBar(context);
    final pass = StatusTone.of(context, CheckStatus.pass).foreground;

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _FileBadge(uploaded: resume.isUploaded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _cvTitle(resume),
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
                      _SelectDot(selected: selected, color: accent),
                    ],
                  ),
                  if (selected) ...[
                    const SizedBox(height: 10),
                    Divider(height: 1, color: accent.withValues(alpha: 0.2)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (onPreview != null)
                          TextButton.icon(
                            onPressed: onPreview,
                            style: TextButton.styleFrom(
                              foregroundColor: accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: const Text('Preview this CV'),
                          ),
                        const Spacer(),
                        Icon(Icons.check_rounded, size: 16, color: pass),
                        const SizedBox(width: 4),
                        Text(
                          'Selected',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: pass,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled circle with a tick when selected, empty ring otherwise.
class _SelectDot extends StatelessWidget {
  const _SelectDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: Border.all(
          color: selected ? color : Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}

/// Red "PDF" badge for uploaded files, violet document icon for CVs built
/// in the app.
class _FileBadge extends StatelessWidget {
  const _FileBadge({required this.uploaded});

  final bool uploaded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fail = StatusTone.of(context, CheckStatus.fail);
    return Container(
      width: 38,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: uploaded ? fail.background : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: uploaded
          ? Text(
              'PDF',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fail.foreground,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(
              Icons.description_outlined,
              size: 20,
              color: ApplyFlowColors.appBar(context),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: ApplyFlowColors.section(context),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
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

/// Dashed "Upload a new CV" box, clearly different from the saved CVs.
class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = ApplyFlowColors.appBar(context);
    return CustomPaint(
      painter: _DashedBorderPainter(color: accent.withValues(alpha: 0.5)),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.upload_rounded, color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload a new CV',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PDF or DOCX, up to 5 MB. Saved to your profile.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

/// "Sending: Staff Nurse CV 2026" above the Continue button.
class _SendingLine extends StatelessWidget {
  const _SendingLine({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.description_outlined, size: 16, color: muted),
        const SizedBox(width: 6),
        Text(
          'Sending: ',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
    final accent = ApplyFlowColors.appBar(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.description_outlined, size: 28, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            'Add a CV to apply',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Upload once and it's saved for your next applications.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onUpload,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.upload_rounded, size: 18),
            label: const Text('Upload your CV'),
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
