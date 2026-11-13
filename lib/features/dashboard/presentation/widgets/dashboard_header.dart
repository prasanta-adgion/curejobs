import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/completion_avatar.dart';
import '../../../profile/domain/entities/candidate.dart';
import '../../../profile/presentation/bloc/candidate_profile_bloc.dart';

/// Greeting, notifications bell and profile avatar. Reads the signed-in
/// candidate from [CandidateProfileBloc]. Drawn on the navy dashboard
/// header, so colours are fixed rather than taken from the theme.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    this.hasUnreadNotifications = false,
    this.onNotificationsTap,
    this.onAvatarTap,
  });

  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;

  static const background = AppColors.logoNavy;
  static const outline = AppColors.darkInputBorder;
  static const muted = AppColors.darkTextSecondary;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CandidateProfileBloc, CandidateProfileState>(
      buildWhen: (prev, curr) =>
          prev.candidate != curr.candidate || prev.status != curr.status,
      builder: (context, state) {
        final candidate = state.candidate;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 2),
                  _Name(
                    candidate: candidate,
                    failed: state.status == CandidateProfileStatus.failure,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onNotificationsTap,
              tooltip: 'Notifications',
              style: IconButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.white.withValues(alpha: 0.10),
                minimumSize: const Size.square(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Badge(
                isLabelVisible: hasUnreadNotifications,
                smallSize: 8,
                backgroundColor: AppColors.errorDark,
                child: const Icon(Icons.notifications_none_rounded, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            CompletionAvatar(
              initials: candidate?.initials,
              percent: candidate?.profileCompletionPercent,
              onTap: onAvatarTap,
            ),
          ],
        );
      },
    );
  }
}

/// Candidate's name, a grey bar while loading, or a neutral fallback if the
/// profile couldn't be loaded.
class _Name extends StatelessWidget {
  const _Name({required this.candidate, required this.failed});

  final Candidate? candidate;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge
        ?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600);
    final name = candidate?.fullName;

    if (name == null && !failed) {
      return Semantics(
        label: 'Loading your name',
        child: Container(
          width: 150,
          height: 22,
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceSecondary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    return Text(
      name == null || name.isEmpty ? 'Welcome back' : name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}
