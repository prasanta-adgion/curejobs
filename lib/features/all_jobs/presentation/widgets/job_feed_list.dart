import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../job_details/presentation/pages/job_details_page.dart';
import '../../domain/entities/job_feed.dart';
import '../bloc/jobs_bloc.dart';
import 'job_card.dart';

/// A full, paginated list of one [JobFeed], with pull to refresh.
/// Owns its own [JobsBloc] and stays alive when its tab is hidden.
class JobFeedList extends StatefulWidget {
  const JobFeedList({super.key, required this.feed});

  final JobFeed feed;

  @override
  State<JobFeedList> createState() => _JobFeedListState();
}

class _JobFeedListState extends State<JobFeedList>
    with AutomaticKeepAliveClientMixin {
  static const _loadMoreThreshold = 400.0;

  late final JobsBloc _bloc = sl<JobsBloc>(param1: widget.feed)
    ..add(const JobsRequested());

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    final state = _bloc.state;
    if (n.metrics.extentAfter < _loadMoreThreshold &&
        state.hasMore &&
        !state.isLoadingMore &&
        state.errorMessage == null) {
      _bloc.add(const JobsNextPageRequested());
    }
    return false;
  }

  Future<void> _refresh() async {
    _bloc.add(const JobsRequested());
    await _bloc.stream.firstWhere((s) => s.status != JobsStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<JobsBloc, JobsState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state.status == JobsStatus.initial ||
            (state.status == JobsStatus.loading && state.jobs.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == JobsStatus.failure && state.jobs.isEmpty) {
          return _Message(
            icon: Icons.wifi_off_rounded,
            title: "Couldn't load jobs",
            body: state.errorMessage ?? 'Check your connection.',
            actionLabel: 'Retry',
            onAction: () => _bloc.add(const JobsRequested()),
          );
        }
        if (state.jobs.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: c.maxHeight,
                  child: _Message(
                    icon: Icons.work_outline_rounded,
                    title: widget.feed == JobFeed.recommended
                        ? 'No recommendations yet'
                        : 'No jobs yet',
                    body: widget.feed == JobFeed.recommended
                        ? 'Complete your profile to get better matches.'
                        : 'New openings will show up here.',
                  ),
                ),
              ),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              itemCount: state.jobs.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (i == state.jobs.length)
                  return _Footer(state: state, bloc: _bloc);
                final job = state.jobs[i];
                return JobCard(
                  job: job,
                  onTap: () =>
                      Navigator.of(context).push(JobDetailsPage.route(job)),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.bloc});

  final JobsState state;
  final JobsBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.errorMessage != null && state.hasMore) {
      return Center(
        child: TextButton(
          onPressed: () => bloc.add(const JobsNextPageRequested()),
          child: const Text('Load more jobs'),
        ),
      );
    }
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            "You've seen all jobs",
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
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
    final muted = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: muted),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
