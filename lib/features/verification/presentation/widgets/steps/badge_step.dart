import 'package:flutter/material.dart';

import 'package:curejobs/app/theme/app_colors.dart';
import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';

import '../common/verification_hero.dart';
import '../common/verification_info_row.dart';
import '../common/verification_scaffold.dart';

/// Step 4 — verification approved and the badge is live: confirmation,
/// how recruiters see the user, and badge details (verified on, renewal).
class BadgeStep extends StatelessWidget {
  const BadgeStep({
    super.key,
    required this.autoRenew,
    this.verifiedAt,
    this.planActiveUntil,
    this.profileName,
    this.profileSubtitle,
  });

  final bool autoRenew;
  final String? verifiedAt;
  final String? planActiveUntil;
  final String? profileName;
  final String? profileSubtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = isDark ? AppColors.successDark : AppColors.success;
    final greenBg = isDark
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.successLight;

    final details = [
      if (verifiedAt != null) ('Verified on', verifiedAt!, null),
      if (planActiveUntil != null) ('Active until', planActiveUntil!, null),
      ('Renews', autoRenew ? 'Automatically' : 'Off', autoRenew ? green : null),
    ];

    return VerificationSections(
      children: [
        ProfileSection(
          title: 'Badge',
          child: VerificationHero(
            icon: Icons.verified_outlined,
            color: green,
            background: greenBg,
            title: "You're verified",
            subtitle: 'Your badge shows on your profile and applications.',
          ),
        ),
        if (profileName != null)
          ProfileSection(
            title: 'How recruiters see you',
            child: RecruiterPreview(
              name: profileName!,
              subtitle: profileSubtitle,
            ),
          ),
        ProfileSection(
          title: 'Details',
          child: Column(
            children: [
              for (var i = 0; i < details.length; i++)
                VerificationInfoRow(
                  label: details[i].$1,
                  value: details[i].$2,
                  valueColor: details[i].$3,
                  showDivider: i < details.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Avatar with initials, name with the verified tick, and a subtitle — a
/// preview of the user's card as recruiters see it.
class RecruiterPreview extends StatelessWidget {
  const RecruiterPreview({super.key, required this.name, this.subtitle});

  final String name;
  final String? subtitle;

  /// "Dr. Asha Rao" → "AR" (the "Dr." prefix is skipped).
  static String initials(String name) {
    final parts = name
        .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primaryContainer,
          child: Text(
            initials(name),
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.verified, size: 18, color: scheme.primary),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
