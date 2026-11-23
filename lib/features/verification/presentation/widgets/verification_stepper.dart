import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/verification_document_type.dart';

/// Plan → Documents → Review → Badge. Finished steps are green with a tick,
/// the current one is outlined in the primary colour.
class VerificationStepper extends StatelessWidget {
  const VerificationStepper({super.key, required this.current});

  final VerificationStep current;

  static const _labels = ['Plan', 'Documents', 'Review', 'Badge'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // On the badge step every step is finished.
    final at = current == VerificationStep.badge
        ? _labels.length
        : current.index;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            _Step(index: i, label: _labels[i], done: i < at, active: i == at),
            if (i < _labels.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(top: 11),
                  color: i < at ? AppColors.success : scheme.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.label,
    required this.done,
    required this.active,
  });

  final int index;
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color border = done
        ? AppColors.success
        : active
        ? scheme.primary
        : scheme.outline;

    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.success : scheme.surface,
              border: Border.all(color: border, width: active ? 2 : 1.5),
            ),
            child: done
                ? const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.white,
                  )
                : Text(
                    '${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: active ? scheme.primary : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: active ? scheme.onSurface : scheme.onSurfaceVariant,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
