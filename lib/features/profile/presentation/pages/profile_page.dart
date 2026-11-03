import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../bloc/candidate_profile_bloc.dart';
import '../bloc/logout_bloc.dart';
import '../models/candidate_profile.dart';
import '../../edit_profile/presentation/pages/edit_profile_page.dart';
import '../../sections/education/presentation/widgets/education_tab.dart';
import '../../sections/experience/presentation/widgets/experience_tab.dart';
import '../widgets/overview_tab.dart';
import '../widgets/profile_header.dart';
import '../widgets/resume_tab.dart';

/// Candidate profile: navy header with tabs for overview, experience,
/// education and resume. The header shows the signed-in candidate from the
/// API; the tabs still use sample data. Actions are left to the caller.
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.profile = ProfileSampleData.candidate,
    this.onEditProfile,
    this.onSettings,
    this.onChangePhoto,
    this.onEditAbout,
    this.onEditSkills,
    this.onAddExperience,
    this.onEditExperience,
    this.onAddEducation,
    this.onEditEducation,
    this.onUploadCv,
    this.onViewCv,
    this.onAddCertificate,
    this.onLoggedOut,
  });

  final CandidateProfile profile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onChangePhoto;
  final VoidCallback? onEditAbout;
  final VoidCallback? onEditSkills;
  final VoidCallback? onAddExperience;
  final ValueChanged<ProfileExperience>? onEditExperience;
  final VoidCallback? onAddEducation;
  final ValueChanged<ProfileEducation>? onEditEducation;
  final VoidCallback? onUploadCv;
  final VoidCallback? onViewCv;
  final VoidCallback? onAddCertificate;

  /// Called once the user has been signed out, to leave this screen.
  final VoidCallback? onLoggedOut;

  static const _tabs = ['Overview', 'Experience', 'Education', 'Resume'];

  /// Opens the edit form for the loaded candidate. Reloads the profile when
  /// the form reports a save.
  Future<void> _openEditProfile(BuildContext context) async {
    final bloc = context.read<CandidateProfileBloc>();
    final candidate = bloc.state.candidate;
    if (candidate == null) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditProfilePage(candidate: candidate),
      ),
    );
    if (saved ?? false) bloc.add(const CandidateProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<CandidateProfileBloc>()
                ..add(const CandidateProfileRequested()),
        ),
        BlocProvider(create: (_) => sl<LogoutBloc>()),
      ],
      child: BlocListener<LogoutBloc, LogoutState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          switch (state.status) {
            case LogoutStatus.success:
              onLoggedOut?.call();
            case LogoutStatus.failure:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? "Couldn't log out. Try again.",
                  ),
                ),
              );
            case LogoutStatus.initial || LogoutStatus.loading:
              break;
          }
        },
        child: DefaultTabController(
          length: _tabs.length,
          child: Scaffold(
            backgroundColor: scheme.surface,
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    onEdit: onEditProfile ?? () => _openEditProfile(context),
                    onSettings: onSettings,
                    onChangePhoto: onChangePhoto,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    color: scheme.surface,
                    divider: scheme.outlineVariant,
                    tabBar: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      labelColor: scheme.onSurface,
                      unselectedLabelColor: scheme.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      indicatorColor: scheme.primary,
                      indicatorWeight: 2.5,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerHeight: 0,
                      tabs: [for (final label in _tabs) Tab(text: label)],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  OverviewTab(
                    profile: profile,
                    onEditAbout: onEditAbout,
                    onEditSkills: onEditSkills,
                  ),
                  ExperienceTab(
                    experience: profile.experience,
                    onAdd: onAddExperience,
                    onEdit: onEditExperience,
                  ),
                  EducationTab(
                    education: profile.education,
                    onAdd: onAddEducation,
                    onEdit: onEditEducation,
                  ),
                  ResumeTab(
                    profile: profile,
                    onUploadCv: onUploadCv,
                    onViewCv: onViewCv,
                    onAddCertificate: onAddCertificate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps the tab bar pinned under the header while the page scrolls.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({
    required this.tabBar,
    required this.color,
    required this.divider,
  });

  final TabBar tabBar;
  final Color color;
  final Color divider;

  // Whole pixels, and the child is forced to exactly this height, so the
  // sliver's layout and paint extents always agree.
  static const _extent = 49.0;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border(bottom: BorderSide(color: divider)),
        ),
        child: Align(alignment: Alignment.bottomLeft, child: tabBar),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.tabBar != tabBar || old.color != color || old.divider != divider;
}
