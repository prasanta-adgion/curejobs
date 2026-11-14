import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../all_jobs/presentation/widgets/job_card.dart';
import '../../../job_details/presentation/pages/job_details_page.dart';
import '../../domain/entities/search_query.dart';
import '../bloc/job_search_results_bloc.dart';
import '../widgets/search_fields_card.dart';
import 'job_search_page.dart';

/// Results screen for a search: the query in a tappable bar (tap to edit)
/// and a paginated list of matching jobs from `api/v1/jobs`.
class JobSearchResultsPage extends StatefulWidget {
  const JobSearchResultsPage({super.key, required this.query});

  final SearchQuery query;

  static Route<void> route(SearchQuery query) =>
      MaterialPageRoute(builder: (_) => JobSearchResultsPage(query: query));

  @override
  State<JobSearchResultsPage> createState() => _JobSearchResultsPageState();
}

class _JobSearchResultsPageState extends State<JobSearchResultsPage> {
  static const _loadMoreThreshold = 400.0;

  late final _query = ValueNotifier<SearchQuery>(widget.query);

  /// Owned by this screen and closed in [dispose].
  late final _bloc = sl<JobSearchResultsBloc>()
    ..add(JobSearchRequested(widget.query));

  @override
  void initState() {
    super.initState();
    _query.addListener(_runSearch);
  }

  @override
  void dispose() {
    _query.dispose();
    _bloc.close();
    super.dispose();
  }

  void _runSearch() => _bloc.add(JobSearchRequested(_query.value));

  void _editSearch() {
    Navigator.of(context).pushReplacement(
      JobSearchPage.route(
        initialQuery: _query.value,
        initialField: SearchField.keyword,
      ),
    );
  }

  void _searchAnywhere() => _query.value = _query.value.withLocation('');

  Future<void> _refresh() async {
    _runSearch();
    await _bloc.stream.firstWhere((s) => !s.isLoading);
  }

  bool _onScroll(ScrollNotification n) {
    final state = _bloc.state;
    if (n.metrics.extentAfter < _loadMoreThreshold &&
        state.hasMore &&
        !state.isLoadingMore &&
        state.errorMessage == null) {
      _bloc.add(const JobSearchNextPageRequested());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        titleSpacing: 0,
        title: ValueListenableBuilder(
          valueListenable: _query,
          builder: (context, query, _) =>
              _QueryBar(summary: query.summary, onTap: _editSearch),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit search',
            onPressed: _editSearch,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: BlocBuilder<JobSearchResultsBloc, JobSearchResultsState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state.status == JobSearchResultsStatus.initial ||
              state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == JobSearchResultsStatus.failure) {
            return _Message(
              icon: Icons.wifi_off_rounded,
              title: "Couldn't load jobs",
              body: state.errorMessage ?? 'Check your connection.',
              primaryLabel: 'Retry',
              onPrimary: _runSearch,
            );
          }
          if (state.jobs.isEmpty) return _empty(state.query);

          return NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: state.jobs.length + 2,
                separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 0 : 10),
                itemBuilder: (context, i) {
                  if (i == 0) return _ResultCount(total: state.total);
                  if (i == state.jobs.length + 1) {
                    return _Footer(state: state, bloc: _bloc);
                  }
                  final job = state.jobs[i - 1];
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
      ),
    );
  }

  Widget _empty(SearchQuery query) {
    final keyword = query.keyword.trim();
    final location = query.location.trim();
    final what = keyword.isEmpty ? 'No jobs' : 'No jobs for "$keyword"';
    final where = location.isEmpty
        ? ''
        : ' in ${location.split(',').first.trim()}';

    return _Message(
      icon: Icons.search_off_rounded,
      title: '$what$where',
      body: 'Try a wider area or a shorter keyword.',
      primaryLabel: location.isEmpty ? 'Edit search' : 'Search anywhere',
      onPrimary: location.isEmpty ? _editSearch : _searchAnywhere,
      secondaryLabel: location.isEmpty ? null : 'Edit search',
      onSecondary: _editSearch,
    );
  }
}

/// "12 jobs found" above the list.
class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Text(
        total == 1 ? '1 job found' : '$total jobs found',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.bloc});

  final JobSearchResultsState state;
  final JobSearchResultsBloc bloc;

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
          onPressed: () => bloc.add(const JobSearchNextPageRequested()),
          child: const Text('Load more jobs'),
        ),
      );
    }
    if (!state.hasMore) {
      final scheme = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            "You've seen all results",
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: scheme.outline),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _QueryBar extends StatelessWidget {
  const _QueryBar({required this.summary, required this.onTap});

  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              child: Text(primaryLabel),
            ),
            if (secondaryLabel != null)
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
          ],
        ),
      ),
    );
  }
}
