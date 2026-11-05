import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/completion_avatar.dart';
import '../../../profile/shared/widgets/profile_section.dart';
import 'create_account_header.dart';

/// Header of the finish screen: greeting, completion ring and key facts.
class AllDoneHeader extends StatelessWidget {
  const AllDoneHeader({
    super.key,
    required this.firstName,
    required this.initials,
    required this.percent,
    this.title,
    this.location,
  });

  final String firstName;
  final String? initials;
  final int percent;
  final String? title;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: AppColors.logoNavy,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CreateAccountStatus(label: 'Profile saved'),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CompletionAvatar(
                  initials: initials,
                  percent: percent,
                  size: 72,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstName.isEmpty
                            ? "You're all set"
                            : "You're all set, $firstName",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (title != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          title!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                if (location != null)
                  _Fact(icon: Icons.location_on_outlined, label: location!),
                _Fact(
                  icon: Icons.donut_large_rounded,
                  label: 'Profile $percent% complete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Body of the finish screen: job matches and ways to improve the profile.
class AllDoneBody extends StatelessWidget {
  const AllDoneBody({
    super.key,
    required this.resumeName,
    required this.onViewMatches,
    required this.onUploadResume,
  });

  /// The chosen resume, once there is one.
  final String? resumeName;
  final VoidCallback onViewMatches;
  final VoidCallback onUploadResume;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ProfileSection(
          title: 'Jobs for you',
          showDivider: false,
          child: _NextStepRow(
            icon: Icons.work_outline,
            title: 'Your matches are ready',
            subtitle: 'Based on your role and location',
            onTap: onViewMatches,
          ),
        ),
        ProfileSection(
          title: 'Get more recruiter views',
          child: _NextStepRow(
            icon: Icons.upload_file_outlined,
            title: resumeName == null ? 'Upload your resume' : 'Resume added',
            subtitle: resumeName ?? 'Show recruiters your full history',
            onTap: onUploadResume,
          ),
        ),
      ],
    );
  }
}

class _NextStepRow extends StatelessWidget {
  const _NextStepRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ProfileIconTile(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.outline),
          ],
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
        Icon(icon, size: 15, color: AppColors.darkTextSecondary),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.darkTextSecondary),
        ),
      ],
    );
  }
}
