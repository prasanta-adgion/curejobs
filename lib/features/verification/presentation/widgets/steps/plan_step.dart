import 'package:flutter/material.dart';

import 'package:curejobs/app/theme/app_colors.dart';
import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';

import '../common/privacy_section.dart';
import '../common/verification_hero.dart';
import '../common/verification_scaffold.dart';

/// Step 1 — the user has no active plan with the verified badge, so we
/// explain why to verify, how it works, and link to the plans page.
/// "Upgrade plan" is in the page's bottom bar.
class PlanStep extends StatelessWidget {
  const PlanStep({super.key, required this.onComparePlans});

  final VoidCallback onComparePlans;

  static const _benefits = [
    (
      Icons.shield_outlined,
      'Employers trust you faster',
      'They know your documents were checked by our team.',
    ),
    (
      Icons.visibility_outlined,
      'Get noticed first',
      'Verified profiles appear higher in recruiter searches.',
    ),
    (
      Icons.work_outline_rounded,
      'More interview calls',
      'Your applications carry the badge, so they stand out.',
    ),
    (
      Icons.lock_outline_rounded,
      'Safer for everyone',
      'Keeps fake profiles out of the CureJobs community.',
    ),
  ];

  static const _howItWorks = [
    'Choose a plan that includes the badge',
    'Upload your ID and medical registration',
    'Our team reviews within 2 working days',
    'Your badge goes live on your profile',
  ];

  @override
  Widget build(BuildContext context) {
    return VerificationSections(
      children: [
        const ProfileSection(
          title: 'Verified badge',
          showDivider: false,
          child: VerificationHero(
            icon: Icons.verified_outlined,
            title: 'Stand out as a trusted professional',
            subtitle:
                'A verified badge shows hospitals and clinics that your '
                'identity and qualifications are real.',
          ),
        ),
        ProfileSection(
          title: 'Why get verified',
          child: Column(
            children: [
              for (final (icon, title, body) in _benefits)
                _BenefitRow(icon: icon, title: title, body: body),
            ],
          ),
        ),
        ProfileSection(
          title: 'How it works',
          action: TextButton(
            onPressed: onComparePlans,
            child: const Text('Compare plans'),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _howItWorks.length; i++)
                _HowItWorksRow(number: i + 1, text: _howItWorks[i]),
            ],
          ),
        ),
        const VerificationPrivacySection(),
      ],
    );
  }
}

/// Icon, a short benefit title and one line explaining it.
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.success),
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
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Numbered circle and one step of the flow.
class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
