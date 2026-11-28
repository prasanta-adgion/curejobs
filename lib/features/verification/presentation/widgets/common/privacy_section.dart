import 'package:flutter/material.dart';

import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';

/// "Only our verification team sees your documents." Shown under the start
/// card and the upload form to reassure the user before they share IDs.
class VerificationPrivacySection extends StatelessWidget {
  const VerificationPrivacySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProfileSection(
      title: 'Privacy',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Only our verification team sees your documents.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
