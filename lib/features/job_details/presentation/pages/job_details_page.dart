import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../apply_job/presentation/pages/apply_eligibility_page.dart';
import '../../../apply_job/presentation/widgets/apply_flow_widgets.dart';
import '../../../all_jobs/presentation/formatters/job_formatter.dart';
import '../../domain/usecases/track_apply_start_usecase.dart';
import '../../domain/usecases/track_job_view_usecase.dart';
import '../widgets/job_details_sections.dart';

/// Full details of one job. Apply sits beside the salary at the top; once
/// that scrolls away, a bottom bar with Apply slides in.
class JobDetailsPage extends StatefulWidget {
  const JobDetailsPage({super.key, required this.job, this.onApply});

  final Job job;
  final VoidCallback? onApply;

  static Route<void> route(Job job, {VoidCallback? onApply}) =>
      MaterialPageRoute(
        builder: (_) => JobDetailsPage(job: job, onApply: onApply),
      );

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final _scroll = ScrollController();
  final _headerKey = GlobalKey();
  final _showBottomBar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    sl<TrackJobViewUseCase>()(widget.job.id);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _showBottomBar.dispose();
    super.dispose();
  }

  /// The salary box sits at the bottom of the header, so once the header
  /// has scrolled (nearly) out of view, show the bottom bar.
  void _onScroll() {
    final height = _headerKey.currentContext?.size?.height;
    if (height == null) return;
    _showBottomBar.value = _scroll.offset > height - 24;
  }

  void _apply() {
    // Fire and forget, like the view event.
    sl<TrackApplyStartUseCase>()(widget.job.id);
    if (widget.onApply != null) {
      widget.onApply!();
      return;
    }
    Navigator.of(context).push(ApplyEligibilityPage.route(widget.job));
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final now = DateTime.now();
    final deadline = DeadlineInfo.of(job.applicationDeadline, now);

    // Ordered by what a candidate decides on first: what/where, does it fit
    // me, how long do I have, then the details.
    final sections = <Widget>[
      if (job.matchReasons.isNotEmpty)
        JobMatchSection(reasons: job.matchReasons),
      JobOverviewSection(job: job, now: now, deadline: deadline),
      if (job.description case final html?) JobDescriptionSection(html: html),
      if (JobRequirementsSection.hasAny(job)) JobRequirementsSection(job: job),
      if (job.skills.isNotEmpty) JobSkillsSection(skills: job.skills),
      if (job.categoryName != null || job.specializationName != null)
        JobDepartmentSection(job: job),
      if (JobLocationSection.hasAddress(job)) JobLocationSection(job: job),
      JobEmployerSection(job: job),
    ];

    return Scaffold(
      backgroundColor: ApplyFlowColors.page(context),
      appBar: ApplyStepAppBar(
        title: 'Job details',
        subtitle: job.organization.name,
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: JobDetailsHeader(
              key: _headerKey,
              job: job,
              now: now,
              onApply: _apply,
            ),
          ),
          if (deadline != null)
            SliverToBoxAdapter(child: JobDeadlineStrip(deadline: deadline)),
          SliverList.list(
            children: [
              for (final section in sections) ...[
                const ApplySectionGap(),
                section,
              ],
              // Room so the bottom bar never covers the last section.
              const SizedBox(height: 88),
            ],
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _showBottomBar,
        builder: (context, visible, child) => AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: visible ? child : const SizedBox(width: double.infinity),
        ),
        child: _ApplyBar(job: job, deadline: deadline, onApply: _apply),
      ),
    );
  }
}

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({
    required this.job,
    required this.deadline,
    required this.onApply,
  });

  final Job job;
  final DeadlineInfo? deadline;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final salary = JobFormatter.salary(job);
    final closed = job.isClosed || (deadline?.isClosed ?? false);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Container(
      decoration: BoxDecoration(
        color: ApplyFlowColors.section(context),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (salary == null)
                      Text('Salary not disclosed', style: muted)
                    else
                      Text.rich(
                        TextSpan(
                          text: salary,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: JobFormatter.salaryPeriod(job.salaryPeriod),
                              style: muted,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (deadline case final d?)
                      Text(
                        d.shortLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: d.color(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: closed ? null : onApply,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                child: Text(closed ? 'Closed' : 'Apply now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
