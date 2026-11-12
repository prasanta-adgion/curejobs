import 'package:curejobs/core/utils/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/completion_avatar.dart';
import '../../../../shared/widgets/theme_mode_button.dart';
import '../../domain/entities/candidate.dart';
import '../bloc/candidate_profile_bloc.dart';

/// Navy top section of the profile. Reads [CandidateProfileBloc] and shows a
/// placeholder while loading, a retry message on error, or the candidate.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.onEdit,
    this.onSettings,
    this.onChangePhoto,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onSettings;
  final VoidCallback? onChangePhoto;

  static const _background = AppColors.logoNavy;
  static const _outline = AppColors.darkInputBorder;
  static const _muted = AppColors.darkTextSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _background,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<CandidateProfileBloc, CandidateProfileState>(
          builder: (context, state) {
            final candidate = state.candidate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompletionAvatar(
                      initials: candidate?.initials,
                      photoUrl: state.photoUrl,
                      percent: candidate?.profileCompletionPercent,
                      size: 80,
                      longLabel: true,
                      onTap: candidate == null ? null : onChangePhoto,
                      topRightBadge: candidate == null
                          ? null
                          : const _CameraBadge(),
                    ),
                    const Spacer(),
                    // Material buttons reserve a 48px tap area around their
                    // 38px box, while ThemeModeButton is exactly 38px.
                    // Centring them in their own row lines the boxes up.
                    Row(
                      children: [
                        _HeaderButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          onPressed: candidate == null ? null : onEdit,
                        ),
                        const SizedBox(width: 8),
                        const ThemeModeButton(onDarkBackground: true),
                        // Hidden until there's a settings screen to open.
                        if (onSettings != null) ...[
                          const SizedBox(width: 8),
                          _HeaderButton(
                            icon: Icons.settings_outlined,
                            tooltip: 'Settings',
                            onPressed: onSettings,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (candidate != null)
                  _CandidateDetails(candidate: candidate)
                else if (state.status == CandidateProfileStatus.failure)
                  _LoadError(
                    message: state.errorMessage,
                    onRetry: () => context.read<CandidateProfileBloc>().add(
                      const CandidateProfileRequested(),
                    ),
                  )
                else
                  const _DetailsPlaceholder(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CandidateDetails extends StatelessWidget {
  const _CandidateDetails({required this.candidate});

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = candidate.professionalTitle?.trim();
    final location = candidate.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                candidate.fullName,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (candidate.verification.isVerifiedAt(DateTime.now())) ...[
              const SizedBox(width: 6),
              const Tooltip(
                message: 'Verified profile',
                child: Icon(
                  Icons.verified,
                  size: 20,
                  color: AppColors.darkPrimary,
                ),
              ),
            ],
          ],
        ),
        if (title != null && title.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            if (location != null)
              _Fact(icon: Icons.location_on_outlined, label: location),
            _Fact(
              icon: candidate.isProfileComplete
                  ? Icons.task_alt_rounded
                  : Icons.donut_large_rounded,
              label: candidate.isProfileComplete
                  ? 'Profile complete'
                  : 'Profile ${candidate.profileCompletionPercent}% complete',
            ),
          ],
        ),
      ],
    );
  }
}

/// Grey bars in the shape of the name, title and facts while loading.
class _DetailsPlaceholder extends StatelessWidget {
  const _DetailsPlaceholder();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Semantics(
      label: 'Loading profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(180, 22),
          const SizedBox(height: 10),
          bar(120, 14),
          const SizedBox(height: 14),
          bar(210, 12),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry, this.message});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          size: 20,
          color: ProfileHeader._muted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message ?? "Couldn't load your profile.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: AppColors.darkPrimary),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

/// Small camera dot on the avatar, hinting that the photo can be changed.
class _CameraBadge extends StatelessWidget {
  const _CameraBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(color: ProfileHeader._background, width: 2),
      ),
      child: const Icon(
        Icons.photo_camera_outlined,
        size: 12,
        color: AppColors.white,
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    this.label,
    this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String? label;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: ProfileHeader._outline),
    );

    if (label == null) {
      return IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: AppColors.white,
          shape: shape,
          minimumSize: const Size.square(38),
        ),
        icon: Icon(icon, size: 18, color: AppColors.white),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.white,
        shape: shape,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      icon: Icon(icon, size: 16, color: AppColors.white),
      label: Text(
        label!,
        style: context.textStyles.bodyMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: ProfileHeader._muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: ProfileHeader._muted),
        ),
      ],
    );
  }
}
