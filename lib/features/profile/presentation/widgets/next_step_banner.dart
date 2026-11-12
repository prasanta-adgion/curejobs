import 'package:flutter/material.dart';

/// One thing the candidate can do to complete their profile.
class ProfileNextStep {
  const ProfileNextStep({
    required this.icon,
    required this.title,
    required this.onPressed,
    this.actionLabel = 'Add',
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onPressed;
}

/// Light purple card at the top of Overview showing the single most useful
/// missing item. Shows nothing once every step is done.
class NextStepBanner extends StatelessWidget {
  const NextStepBanner({super.key, required this.steps});

  /// Missing items, most important first. Only the first is shown.
  final List<ProfileNextStep> steps;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final step = steps.first;
    final left = steps.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: step.onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Icon(step.icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        left == 1
                            ? 'Next step · last one to complete your profile'
                            : 'Next step · $left left to complete your profile',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: step.onPressed,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(step.actionLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
