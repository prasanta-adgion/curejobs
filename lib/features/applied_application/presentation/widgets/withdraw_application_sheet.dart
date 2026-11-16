import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../models/application_ui_model.dart';

/// Asks before withdrawing an application. Returns `true` on confirm.
Future<bool> showWithdrawApplicationSheet(
  BuildContext context,
  JobApplication application,
) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => WithdrawApplicationSheet(application: application),
  );
  return confirmed ?? false;
}

class WithdrawApplicationSheet extends StatelessWidget {
  const WithdrawApplicationSheet({super.key, required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.5,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.medium),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(Icons.undo_rounded, color: scheme.error, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              'Withdraw application?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: application.jobTitle,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' will stop reviewing your profile. You can reapply '
                        'later if the job is still open.',
                  ),
                ],
              ),
              style: muted,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(shape: buttonShape),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Keep it'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                        shape: buttonShape,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Withdraw'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
