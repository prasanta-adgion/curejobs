import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../domain/entities/search_query.dart';
import '../widgets/search_fields_card.dart';
import 'job_search_page.dart';

/// Results screen for a search: the query in a tappable bar (tap to edit)
/// and the result area. No search API is connected, so the result area
/// shows the empty state with ways to change the search.
class JobSearchResultsPage extends StatefulWidget {
  const JobSearchResultsPage({super.key, required this.query});

  final SearchQuery query;

  static Route<void> route(SearchQuery query) =>
      MaterialPageRoute(builder: (_) => JobSearchResultsPage(query: query));

  @override
  State<JobSearchResultsPage> createState() => _JobSearchResultsPageState();
}

class _JobSearchResultsPageState extends State<JobSearchResultsPage> {
  late final _query = ValueNotifier<SearchQuery>(widget.query);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _editSearch() {
    Navigator.of(context).pushReplacement(
      JobSearchPage.route(
        initialQuery: _query.value,
        initialField: SearchField.keyword,
      ),
    );
  }

  void _searchAnywhere() => _query.value = _query.value.copyWith(location: '');

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
      body: ValueListenableBuilder(
        valueListenable: _query,
        builder: (context, query, _) {
          final keyword = query.keyword.trim();
          final location = query.location.trim();
          final what = keyword.isEmpty ? 'No jobs' : 'No jobs for "$keyword"';
          final where = location.isEmpty
              ? ''
              : ' in ${location.split(',').first.trim()}';

          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: _Message(
                  icon: Icons.search_off_rounded,
                  title: '$what$where',
                  body: 'Try a wider area or a shorter keyword.',
                  primaryLabel: location.isEmpty
                      ? 'Edit search'
                      : 'Search anywhere',
                  onPrimary: location.isEmpty ? _editSearch : _searchAnywhere,
                  secondaryLabel: location.isEmpty ? null : 'Edit search',
                  onSecondary: _editSearch,
                ),
              ),
            ],
          );
        },
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
