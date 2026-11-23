import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_back_button.dart';

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
          leading: AppBackButton.leadingOf(context, color: AppColors.white),
          titleSpacing: 16,
          backgroundColor: AppColors.logoNavy,
          surfaceTintColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jobs', style: TextStyle(color: AppColors.white)),
              Text(
                'Browse all openings and picks for you',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.darkTextSecondary,
            indicatorColor: AppColors.white,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall,
            dividerColor: scheme.outlineVariant,
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
