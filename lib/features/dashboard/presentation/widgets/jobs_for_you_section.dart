import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/job.dart';
import '../bloc/jobs_bloc.dart';
import 'job_card.dart';

/// "JOBS FOR YOU" heading and list, as slivers. Reads [JobsBloc] and shows
/// placeholders, an error with retry, an empty message, or the jobs.
class JobsForYouSection extends StatelessWidget {
  const JobsForYouSection({super.key, this.onJobTap});

  final ValueChanged<Job>? onJobTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobsBloc, JobsState>(
      builder: (context, state) {
        void retry() => context.read<JobsBloc>().add(const JobsRequested());

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(child: _Heading(state: state)),
            if (state.isInitialLoading)
              SliverList.list(
                children: const [
                  _JobPlaceholder(),
                  _JobPlaceholder(),
                  _JobPlaceholder(),
                ],
              )
            else if (state.jobs.isEmpty && state.status == JobsStatus.failure)
              SliverToBoxAdapter(
                child: _Message(
                  icon: Icons.cloud_off_rounded,
                  title: "Couldn't load jobs",
                  body: state.errorMessage ?? 'Check your connection.',
                  actionLabel: 'Retry',
                  onAction: retry,
                ),
              )
            else if (state.jobs.isEmpty)
              const SliverToBoxAdapter(
                child: _Message(
                  icon: Icons.work_off_outlined,
                  title: 'No jobs yet',
                  body: 'New openings will show up here.',
                ),
              )
            else ...[
              SliverList.separated(
                itemCount: state.jobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final job = state.jobs[index];
                  return JobCard(
                    job: job,
                    onTap: onJobTap == null ? null : () => onJobTap!(job),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: _ListFooter(
                  state: state,
                  onRetry: () => context.read<JobsBloc>().add(
                    const JobsNextPageRequested(),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.state});

  final JobsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = state.total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Text(
            'Recommended JOBS FOR YOU'.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              // color: scheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          if (state.status == JobsStatus.success || state.jobs.isNotEmpty)
            Text(
              count == 1 ? '1 job' : '$count jobs',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Spinner while the next page loads, or a retry if it failed.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state, required this.onRetry});

  final JobsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (state.hasMore && state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Load more jobs'),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: scheme.outline),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Grey shape of a job row while the first page loads.
class _JobPlaceholder extends StatelessWidget {
  const _JobPlaceholder();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget box(double width, double height, {double radius = 6}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          box(42, 42, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                box(160, 14),
                const SizedBox(height: 8),
                box(110, 12),
                const SizedBox(height: 14),
                Row(
                  children: [
                    box(64, 20),
                    const SizedBox(width: 6),
                    box(64, 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
