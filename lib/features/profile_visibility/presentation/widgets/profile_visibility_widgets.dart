import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/theme_extensions.dart';
import '../../../profile/shared/widgets/profile_section.dart';
import '../../../subscription_packages/presentation/widgets/package_widgets.dart';
import '../../domain/entities/match_privacy.dart';
import '../../domain/entities/profile_activity.dart';
import '../bloc/profile_visibility_bloc.dart';

/// Thin line between rows, as on the other profile screens.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: context.colors.outlineVariant);
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: context.textStyles.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );
}

/// Short explanation shown right under a section title.
class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: context.textStyles.bodySmall?.copyWith(
        color: context.colors.onSurfaceVariant,
        height: 1.4,
      ),
    ),
  );
}

/// Toggles for `match-privacy`.
class MatchPrivacySection extends StatelessWidget {
  const MatchPrivacySection({
    super.key,
    required this.privacy,
    required this.savingSetting,
    required this.onDiscoverableChanged,
    required this.onShareContactChanged,
    this.showDivider = true,
  });

  final MatchPrivacy? privacy;

  /// Switch currently being saved; it shows a spinner, the other is locked.
  final PrivacySetting? savingSetting;
  final ValueChanged<bool> onDiscoverableChanged;
  final ValueChanged<bool> onShareContactChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final p = privacy;
    return ProfileSection(
      title: 'Profile visibility',
      showDivider: showDivider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Subtitle(
            'Choose whether hospitals and clinics can find you and how they '
            'can contact you.',
          ),
          if (p == null)
            const _Note(
              "We couldn't load your settings. Pull down to try again.",
            )
          else ...[
            _PrivacySwitchRow(
              icon: Icons.travel_explore_rounded,
              title: 'Let employers find me',
              subtitle:
                  'Your profile is suggested to employers when it matches '
                  'their open jobs. Turn off to stay hidden.',
              value: p.matchDiscoverable,
              isSaving: savingSetting == PrivacySetting.discoverable,
              enabled: savingSetting == null,
              onChanged: onDiscoverableChanged,
            ),
            const SizedBox(height: 10),
            _PrivacySwitchRow(
              icon: Icons.contact_phone_outlined,
              title: 'Show my phone and email',
              subtitle:
                  'When an employer opens your full profile, they can see '
                  'your phone number and email to contact you.',
              value: p.shareContactOnReveal,
              isSaving: savingSetting == PrivacySetting.shareContact,
              enabled: savingSetting == null,
              onChanged: onShareContactChanged,
            ),
          ],
        ],
      ),
    );
  }
}

/// Employers who revealed the profile (`profile-activity`).
class ProfileActivitySection extends StatelessWidget {
  const ProfileActivitySection({
    super.key,
    required this.activity,
    this.showDivider = true,
  });

  final ProfileActivity? activity;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final secondary = context.textStyles.bodySmall?.copyWith(
      color: context.colors.onSurfaceVariant,
    );
    return ProfileSection(
      title: 'Profile activity',
      count: a == null || a.total == 0 ? null : a.total,
      showDivider: showDivider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Subtitle(
            'Hospitals and clinics that opened your full profile to see your '
            'details. This usually means they are interested in hiring you.',
          ),
          if (a == null)
            const _Note("We couldn't load this list. Pull down to try again.")
          else if (a.items.isEmpty)
            const _Note(
              'No employer has opened your full profile yet. Keep your '
              'profile complete to get noticed.',
            )
          else ...[
            for (var i = 0; i < a.items.length; i++) ...[
              if (i > 0) const _RowDivider(),
              _ActivityRow(item: a.items[i], dateStyle: secondary),
            ],
            if (a.lockedCount > 0) ...[
              const _RowDivider(),
              _Note(
                '${a.lockedCount} more '
                '${a.lockedCount == 1 ? 'employer has' : 'employers have'} '
                'viewed your profile. Upgrade your plan to see who.',
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, this.dateStyle});

  final ProfileActivityItem item;
  final TextStyle? dateStyle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ProfileIconTile(
        icon: item.isRevealed
            ? Icons.lock_open_rounded
            : Icons.visibility_outlined,
      ),
      title: Text(item.organizationName),
      subtitle: Text(
        item.jobTitle != null
            ? 'Viewed your full profile for their ${item.jobTitle} job'
            : item.isRevealed
            ? 'Viewed your full profile'
            : 'Looked at your profile',
      ),
      trailing: item.at == null
          ? null
          : Text(PackageFormat.date(item.at!), style: dateStyle),
    );
  }
}

/// Shown when the plan lacks the feature.
class LockedFeatureSection extends StatelessWidget {
  const LockedFeatureSection({
    super.key,
    required this.title,
    required this.body,
    required this.onUpgrade,
    this.showDivider = true,
  });
  final String title;
  final String body;
  final VoidCallback onUpgrade;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: title,
      showDivider: showDivider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ProfileIconTile(
              icon: Icons.lock_outline_rounded,
              background: context.colors.surfaceContainerHighest,
              color: context.colors.onSurfaceVariant,
            ),
            title: const Text('Not included in your plan'),
            subtitle: Text(body),
          ),
          const SizedBox(height: 4),
          FilledButton(onPressed: onUpgrade, child: const Text('Upgrade plan')),
        ],
      ),
    );
  }
}

/// A setting row whose switch turns into a small spinner while it saves.
class _PrivacySwitchRow extends StatelessWidget {
  const _PrivacySwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isSaving,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool isSaving;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isSaving;
    // White card; Material (not a coloured Container) so the tap ink shows.
    return Material(
      color: context.colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
        leading: ProfileIconTile(icon: icon),

        title: Text(title, style: context.textStyles.bodyMedium),
        subtitle: Text(
          subtitle,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        onTap: canTap ? () => onChanged(!value) : null,
        trailing: SizedBox(
          width: 52,
          height: 32,
          child: Center(
            child: isSaving
                ? SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: context.colors.primary,
                    ),
                  )
                : Switch.adaptive(
                    value: value,
                    onChanged: canTap ? onChanged : null,
                  ),
          ),
        ),
      ),
    );
  }
}
