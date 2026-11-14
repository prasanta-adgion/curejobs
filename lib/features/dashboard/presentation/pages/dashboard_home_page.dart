import 'package:curejobs/features/appearance_page.dart';
import 'package:curejobs/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../profile/presentation/bloc/candidate_profile_bloc.dart';
import '../../../all_jobs/domain/entities/job_feed.dart';
import '../../../all_jobs/presentation/bloc/jobs_bloc.dart';
import '../models/job_filters.dart';
import '../widgets/dashboard_compact_search.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/job_filter_chips.dart';
import '../widgets/jobs_for_you_section.dart';
import '../widgets/profile_completion_card.dart';
import '../../../job_details/presentation/pages/job_details_page.dart';
import '../../../search_job/domain/entities/search_query.dart';
import '../../../search_job/presentation/cubit/search_history_cubit.dart';
import '../../../search_job/presentation/pages/job_search_page.dart';
import '../../../search_job/presentation/pages/job_search_results_page.dart';
import '../../../search_job/presentation/widgets/recent_search_chips.dart';
import '../../../search_job/presentation/widgets/search_fields_card.dart';

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
        // Reuses the profile feature's bloc for the greeting and nudge.
        BlocProvider(
          create: (_) =>
              sl<CandidateProfileBloc>()
                ..add(const CandidateProfileRequested()),
        ),
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
  final _keywordFocus = FocusNode();
  final _keywordController = TextEditingController();
  final _locationController = TextEditingController(
    text: 'Kolkata, West Bengal',
  );

  // Notifiers keep filter changes and the compact bar local to the widgets
  // that use them instead of rebuilding the whole page.
  final _showCompactSearch = ValueNotifier(false);
  final _jobTypes = ValueNotifier<Set<JobType>>({});
  final _experience = ValueNotifier<ExperienceLevel?>(null);
  final _datePosted = ValueNotifier<DatePosted?>(null);

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
    _keywordFocus.dispose();
    _keywordController.dispose();
    _locationController.dispose();
    _showCompactSearch.dispose();
    _jobTypes.dispose();
    _experience.dispose();
    _datePosted.dispose();
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
    final bloc = context.read<JobsBloc>()..add(const JobsRequested());
    await bloc.stream.firstWhere((state) => state.status != JobsStatus.loading);
  }

  String get _searchSummary {
    final keyword = _keywordController.text.trim();
    final city = _locationController.text.split(',').first.trim();
    final parts = [
      keyword.isEmpty ? 'All jobs' : keyword,
      if (city.isNotEmpty) city,
    ];
    return parts.join(' · ');
  }

  /// Last query put in the fields (from a recent search), with its ids and
  /// place parts, so Find jobs and the search screen keep them.
  SearchQuery _lastQuery = const SearchQuery();

  /// The field text plus [_lastQuery]'s filters; a field whose text no
  /// longer matches loses its ids/place parts.
  SearchQuery get _currentQuery {
    final keyword = _keywordController.text.trim();
    final location = _locationController.text.trim();
    var q = _lastQuery;
    if (keyword != q.keyword.trim()) q = q.withKeyword(keyword);
    if (location != q.location.trim()) q = q.withLocation(location);
    return q;
  }

  void _openSearch([SearchField field = SearchField.keyword]) {
    Navigator.of(context).push(
      JobSearchPage.route(initialQuery: _currentQuery, initialField: field),
    );
  }

  /// Searches straight away when a keyword is set, otherwise opens the
  /// search screen so the user can type one.
  void _findJobs() {
    final query = _currentQuery;
    if (query.keyword.trim().isEmpty) {
      _openSearch();
      return;
    }
    _showResults(query);
  }

  /// Runs a recent search again with its own keyword and location.
  void _openRecent(SearchQuery query) {
    _lastQuery = query;
    _keywordController.text = query.keyword;
    _locationController.text = query.location;
    _showResults(query);
  }

  void _showResults(SearchQuery query) {
    FocusScope.of(context).unfocus();
    sl<SearchHistoryCubit>().add(query);
    Navigator.of(context).push(JobSearchResultsPage.route(query));
  }

  Future<void> _backToSearch() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _keywordFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refresh,
              edgeOffset: topInset,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      key: _headerKey,
                      color: DashboardHeader.background,
                      padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
                      child: Column(
                        children: [
                          DashboardHeader(
                            hasUnreadNotifications: true,
                            onNotificationsTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AppearancePage(),
                                ),
                              );
                            },
                            onAvatarTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          DashboardSearchBar(
                            keywordController: _keywordController,
                            locationController: _locationController,
                            keywordFocusNode: _keywordFocus,
                            onSearch: _findJobs,
                            onKeywordTap: _openSearch,
                            onLocationTap: () =>
                                _openSearch(SearchField.location),
                            onUseCurrentLocation: () =>
                                _openSearch(SearchField.location),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    sliver: SliverToBoxAdapter(
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
                          onExperienceChanged: (value) =>
                              _experience.value = value,
                          onDatePostedChanged: (value) =>
                              _datePosted.value = value,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: RecentSearchChips(onSelected: _openRecent),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _SectionBand()),
                  SliverToBoxAdapter(
                    child:
                        BlocBuilder<
                          CandidateProfileBloc,
                          CandidateProfileState
                        >(
                          buildWhen: (prev, curr) =>
                              prev.candidate != curr.candidate,
                          builder: (context, state) {
                            final candidate = state.candidate;
                            // Nudge only once loaded, and only while incomplete.
                            if (candidate == null ||
                                candidate.isProfileComplete) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                ProfileCompletionCard(
                                  progress:
                                      candidate.profileCompletionPercent / 100,
                                  nextStep: 'Complete your profile',
                                  reason: 'Complete profiles get more recruiter views',
                                ),
                                const _SectionBand(),
                              ],
                            );
                          },
                        ),
                  ),
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
                      summary: _searchSummary,
                      onTap: _backToSearch,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thick grey band between sections, matching the profile screen.
class _SectionBand extends StatelessWidget {
  const _SectionBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
