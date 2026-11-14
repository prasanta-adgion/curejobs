import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../domain/entities/search_query.dart';
import '../cubit/search_history_cubit.dart';

/// One-tap chips for the latest searches. Hidden when history is empty.
class RecentSearchChips extends StatelessWidget {
  const RecentSearchChips({super.key, required this.onSelected, this.max = 5});

  final ValueChanged<SearchQuery> onSelected;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SearchHistoryCubit, List<SearchQuery>>(
      bloc: sl<SearchHistoryCubit>(),
      builder: (context, history) {
        if (history.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Recent searches',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: history.length.clamp(0, max),
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  avatar: const Icon(Icons.history_rounded, size: 16),
                  label: Text(history[i].summary),
                  onPressed: () => onSelected(history[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
