import 'package:curejobs/features/profile/presentation/pages/profile_page.dart';
import 'package:curejobs/shared/widgets/separation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../profile/presentation/bloc/candidate_profile_bloc.dart';
import '../../../notification/presentation/cubit/unread_notification_count_cubit.dart';
import '../../../notification/presentation/pages/notifications_page.dart';
import '../../../all_jobs/domain/entities/job_feed.dart';
import '../../../all_jobs/presentation/bloc/jobs_bloc.dart';
import '../widgets/dashboard_compact_search.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/jobs_for_you_section.dart';
import '../../../job_details/presentation/pages/job_details_page.dart';
import '../../../search_job/domain/entities/search_query.dart';
import '../../../search_job/presentation/cubit/search_history_cubit.dart';
import '../../../search_job/presentation/pages/job_search_page.dart';
import '../../../search_job/presentation/pages/job_search_results_page.dart';
import '../../../search_job/presentation/widgets/recent_search_chips.dart';

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<JobsBloc>(param1: JobFeed.recommended)
                ..add(const JobsRequested()),
        ),
        // Reuses the profile feature's bloc for the greeting.
        BlocProvider(
          create: (_) =>
              sl<CandidateProfileBloc>()
                ..add(const CandidateProfileRequested()),
        ),
        // Shared singleton: .value so the page doesn't close it.
        BlocProvider.value(value: sl<UnreadNotificationCountCubit>()..load()),
      ],
      child: const _DashboardHomeView(),
    );
  }
}

class _DashboardHomeView extends StatefulWidget {
  const _DashboardHomeView();

  @override
  State<_DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<_DashboardHomeView> {
  /// Start loading the next page this far before the end of the list.
  static const _loadMoreThreshold = 400.0;

  final _scrollController = ScrollController();
  final _headerKey = GlobalKey();

  // Keeps the compact bar's visibility local instead of rebuilding the page.
  final _showCompactSearch = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController
      ..addListener(_updateCompactSearch)
      ..addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showCompactSearch.dispose();
    super.dispose();
  }

  void _updateCompactSearch() {
    final headerHeight = _headerKey.currentContext?.size?.height;
    if (headerHeight == null) return;
    _showCompactSearch.value = _scrollController.offset > headerHeight - 60;
  }

  void _loadMoreNearEnd() {
    final position = _scrollController.position;
    if (position.extentAfter > _loadMoreThreshold) return;
    final state = context.read<JobsBloc>().state;
    // A failed page waits for the "Load more jobs" button instead of
    // retrying on every scroll.
    if (state.hasMore && !state.isLoadingMore && state.errorMessage == null) {
      context.read<JobsBloc>().add(const JobsNextPageRequested());
    }
  }

  Future<void> _refresh() async {
    context.read<UnreadNotificationCountCubit>().load();
    final bloc = context.read<JobsBloc>()..add(const JobsRequested());
    await bloc.stream.firstWhere((state) => state.status != JobsStatus.loading);
  }

  void _openSearch() {
    Navigator.of(context).push(JobSearchPage.route());
  }

  /// Runs a recent search again with its own keyword and location.
  void _openRecent(SearchQuery query) {
    sl<SearchHistoryCubit>().add(query);
    Navigator.of(context).push(JobSearchResultsPage.route(query));
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            edgeOffset: topInset,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    key: _headerKey,
                    color: DashboardHeader.background,
                    padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
                    child: Column(
                      children: [
                        BlocBuilder<UnreadNotificationCountCubit, int>(
                          builder: (context, unreadCount) => DashboardHeader(
                            unreadNotificationCount: unreadCount,
                            onNotificationsTap: () =>
                                Navigator.of(context)
                                    .push(NotificationsPage.route()),
                            onAvatarTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        DashboardSearchBar(onTap: _openSearch),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: RecentSearchChips(onSelected: _openRecent),
                  ),
                ),
                const SliverToBoxAdapter(child: SectionBand()),
                JobsForYouSection(
                  onJobTap: (job) =>
                      Navigator.of(context).push(JobDetailsPage.route(job)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: _showCompactSearch,
              builder: (context, visible, _) => IgnorePointer(
                ignoring: !visible,
                child: AnimatedSlide(
                  offset: visible ? Offset.zero : const Offset(0, -1),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: DashboardCompactSearch(
                    summary: 'Search jobs',
                    onTap: _openSearch,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
