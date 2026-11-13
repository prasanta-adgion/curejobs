import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/job_feed.dart';
import '../widgets/job_feed_list.dart';

/// "Jobs" tab: All jobs and Recommended, each its own paginated list.
class AllJobsPage extends StatelessWidget {
  const AllJobsPage({super.key, this.initialFeed = JobFeed.all});

  final JobFeed initialFeed;

  static const _feeds = [JobFeed.all, JobFeed.recommended];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: _feeds.length,
      initialIndex: _feeds.indexOf(initialFeed),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          titleSpacing: 16,
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Jobs',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            labelColor: scheme.primary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            indicatorColor: scheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall,
            dividerColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            tabs: const [
              Tab(text: 'All jobs'),
              Tab(text: 'Recommended'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            JobFeedList(feed: JobFeed.all),
            JobFeedList(feed: JobFeed.recommended),
          ],
        ),
      ),
    );
  }
}
