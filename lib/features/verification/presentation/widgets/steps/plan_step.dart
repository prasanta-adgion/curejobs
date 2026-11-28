import 'package:flutter/material.dart';

import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';

import '../common/verification_hero.dart';
import '../common/verification_scaffold.dart';

/// Step 1 — the user has no active plan with the verified badge, so we
/// explain why to verify and link to the plans page. "Upgrade plan" is in
/// the page's bottom bar.
class PlanStep extends StatelessWidget {
  const PlanStep({super.key, required this.onComparePlans});

  final VoidCallback onComparePlans;

  @override
  Widget build(BuildContext context) {
    return VerificationSections(
      children: [
        ProfileSection(
          title: 'Why verify',
          action: TextButton(
            onPressed: onComparePlans,
            child: const Text('See plans'),
          ),
          child: const VerificationHero(
            icon: Icons.verified_outlined,
            title: 'Stand out to recruiters',
            subtitle: 'Verified profiles get a badge on every application.',
          ),
        ),
      ],
    );
  }
}
