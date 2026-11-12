import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snackbar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import '../../../../app/di/injection_container.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../shared/widgets/photo_source_sheet.dart';
import '../../../media_preview/domain/enums/media_upload_purpose.dart';
import '../../../media_preview/presentation/pick_and_upload_media.dart';
import '../bloc/candidate_profile_bloc.dart';
import '../bloc/logout_bloc.dart';
import '../models/candidate_profile.dart';
import '../../edit_profile/presentation/pages/edit_profile_page.dart';
import '../widgets/qualifications_tab.dart';
import '../../sections/experience/presentation/widgets/experience_tab.dart';
import '../widgets/overview_tab.dart';
import '../widgets/profile_header.dart';
import '../widgets/resume_tab.dart';

/// Candidate profile: navy header with tabs for overview, experience,
/// qualifications and resume. Each section handles its own actions; only
/// leaving the screen after logout is left to the caller.
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.profile = ProfileSampleData.candidate,
    this.onLoggedOut,
  });

  /// Sample data for sections that don't have an API yet.
  final CandidateProfile profile;

  /// Called once the user has been signed out, to leave this screen.
  final VoidCallback? onLoggedOut;

  static const _tabs = ['Overview', 'Experience', 'Qualifications', 'Resume'];

  /// Opens the edit form for the loaded candidate. Reloads the profile when
  /// the form reports a save.
  Future<void> _openEditProfile(BuildContext context) async {
    final bloc = context.read<CandidateProfileBloc>();
    final candidate = bloc.state.candidate;
    if (candidate == null) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditProfilePage(
          candidate: candidate,
          photoUrl: bloc.state.photoUrl,
        ),
      ),
    );
    if (saved ?? false) bloc.add(const CandidateProfileRequested());
  }

  /// Asks for a camera or gallery photo, previews and uploads it, then shows
  /// it in the header. There is no remove option: the API can't clear a photo.
  Future<void> _changePhoto(BuildContext context) async {
    final bloc = context.read<CandidateProfileBloc>();
    final candidate = bloc.state.candidate;
    if (candidate == null) return;

    final photoUrl = bloc.state.photoUrl;
    final action = await showPhotoSourceSheet(
      context,
      photo: photoUrl == null ? null : NetworkImage(photoUrl),
      initials: candidate.initials,
    );
    if (action == null || !context.mounted) return;

    final source = action == PhotoSheetAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    final picker = ImagePickerService();
    final uploaded = await pickAndUploadMedia(
      context,
      () => picker.pickPhoto(source),
      purpose: MediaUploadPurpose.profilePhoto,
      pickAgainLabel: source == ImageSource.camera ? 'Retake' : 'Change',
      name: candidate.fullName,
      subtitle: candidate.professionalTitle,
    );
    if (uploaded == null) return;

    bloc.add(CandidateProfilePhotoGet(uploaded.fileId));
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
              AppSnackbar.error(
                title: "Couldn't log out",
                message: state.errorMessage ?? 'Try again in a moment.',
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
                    onEdit: () => _openEditProfile(context),
                    onChangePhoto: () => _changePhoto(context),
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
                  OverviewTab(profile: profile),
                  const ExperienceTab(),
                  QualificationsTab(profile: profile),
                  ResumeTab(profile: profile),
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
