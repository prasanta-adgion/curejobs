import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../dashboard/presentation/models/job_filters.dart';
import '../models/search_filters.dart';

/// Bottom sheet with every search filter: job type (any number), experience
/// and date posted (one each). Returns the new filters on "Apply filters",
/// or null when dismissed.
class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key, required this.initial});

  final SearchFilters initial;

  static Future<SearchFilters?> show(
    BuildContext context, {
    required SearchFilters initial,
  }) {
    return showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.extraLarge),
        ),
      ),
      builder: (_) => SearchFilterSheet(initial: initial),
    );
  }

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late SearchFilters _filters = widget.initial;

  void _toggleJobType(JobType type) {
    final types = {..._filters.jobTypes};
    if (!types.remove(type)) types.add(type);
    setState(() => _filters = _filters.copyWith(jobTypes: types));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Divider(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GroupTitle(title: 'Job type', hint: 'pick any'),
                  _Chips(
                    children: [
                      for (final type in JobType.values)
                        FilterChip(
                          label: Text(type.label),
                          selected: _filters.jobTypes.contains(type),
                          onSelected: (_) => _toggleJobType(type),
                        ),
                    ],
                  ),
                  const _GroupTitle(title: 'Experience', hint: 'pick one'),
                  _Chips(
                    children: [
                      for (final level in ExperienceLevel.values)
                        ChoiceChip(
                          label: Text(level.label),
                          selected: _filters.experience == level,
                          onSelected: (on) => setState(
                            () => _filters = _filters.copyWith(
                              experience: () => on ? level : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const _GroupTitle(title: 'Date posted', hint: 'pick one'),
                  _Chips(
                    children: [
                      for (final date in DatePosted.values)
                        ChoiceChip(
                          label: Text(date.label),
                          selected: _filters.datePosted == date,
                          onSelected: (on) => setState(
                            () => _filters = _filters.copyWith(
                              datePosted: () => on ? date : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _filters.isEmpty
                        ? null
                        : () => setState(
                            () => _filters = const SearchFilters(),
                          ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_filters),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: const Text('Apply filters'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text.rich(
        TextSpan(
          text: title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: ' · $hint',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}
