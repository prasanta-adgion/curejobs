import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../dashboard/domain/entities/job.dart';
import '../../../dashboard/presentation/formatters/job_formatter.dart';
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
    // Fire and forget: a failed analytics call never affects the screen.
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
    if (widget.onApply != null) {
      widget.onApply!();
      return;
    }
    // TODO: hook up the apply flow.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Apply coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final isDark = theme.brightness == Brightness.dark;
    final deadline = DeadlineInfo.of(job.applicationDeadline, now);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        // Shows the job title once the header has scrolled away.
        title: ValueListenableBuilder(
          valueListenable: _showBottomBar,
          builder: (context, scrolled, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              scrolled ? job.title : 'Job details',
              key: ValueKey(scrolled),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList.list(
              children: [
                if (job.matchReasons.isNotEmpty) ...[
                  JobMatchSection(reasons: job.matchReasons),
                  const SizedBox(height: 10),
                ],
                JobOverviewSection(job: job, now: now, deadline: deadline),
                if (job.description case final html?) ...[
                  const SizedBox(height: 10),
                  JobDescriptionSection(html: html),
                ],
                if (JobRequirementsSection.hasAny(job)) ...[
                  const SizedBox(height: 10),
                  JobRequirementsSection(job: job),
                ],
                if (job.skills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  JobSkillsSection(skills: job.skills),
                ],
                if (job.categoryName != null ||
                    job.specializationName != null) ...[
                  const SizedBox(height: 10),
                  JobDepartmentSection(job: job),
                ],
                if (JobLocationSection.hasAddress(job)) ...[
                  const SizedBox(height: 10),
                  JobLocationSection(job: job),
                ],
                const SizedBox(height: 10),
                JobEmployerSection(job: job),
                // Room so the bottom bar never covers the last section.
                const SizedBox(height: 72),
              ],
            ),
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
        color: scheme.surface,
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
