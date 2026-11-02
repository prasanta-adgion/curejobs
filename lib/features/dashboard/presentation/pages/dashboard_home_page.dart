import 'package:curejobs/features/appearance_page.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_job.dart';
import '../models/job_filters.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_chips.dart';

/// Home tab: greeting, job and location search, filters and jobs.
class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  static const _horizontalPadding = EdgeInsets.symmetric(horizontal: 20);

  final _keywordController = TextEditingController();
  final _locationController = TextEditingController(
    text: 'Kolkata, West Bengal',
  );

  // Notifiers keep filter changes local to the chips row instead of
  // rebuilding the whole page.
  final _jobTypes = ValueNotifier<Set<JobType>>({});
  final _experience = ValueNotifier<ExperienceLevel?>(null);
  final _datePosted = ValueNotifier<DatePosted?>(null);

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    _jobTypes.dispose();
    _experience.dispose();
    _datePosted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobs = DashboardSampleData.jobs;

    return SafeArea(
      bottom: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              sliver: SliverList.list(
                children: [
                  DashboardHeader(
                    name: 'Ananya Sen',
                    initials: 'AS',
                    hasUnreadNotifications: true,
                    onNotificationsTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AppearancePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  DashboardSearchBar(
                    keywordController: _keywordController,
                    locationController: _locationController,
                    onSearch: () => FocusScope.of(context).unfocus(),
                    onUseCurrentLocation: () {},
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  _jobTypes,
                  _experience,
                  _datePosted,
                ]),
                builder: (context, _) => JobFilterChips(
                  jobTypes: _jobTypes.value,
                  experience: _experience.value,
                  datePosted: _datePosted.value,
                  onJobTypesChanged: (value) => _jobTypes.value = value,
                  onExperienceChanged: (value) => _experience.value = value,
                  onDatePostedChanged: (value) => _datePosted.value = value,
                ),
              ),
            ),
            SliverPadding(
              padding: _horizontalPadding.copyWith(top: 24, bottom: 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text('Jobs for you', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '${jobs.length} jobs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: _horizontalPadding.copyWith(bottom: 24),
              sliver: SliverList.separated(
                itemCount: jobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    JobCard(job: jobs[index], onTap: () {}, onSaveTap: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
