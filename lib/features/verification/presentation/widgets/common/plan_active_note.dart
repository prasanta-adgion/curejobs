import 'package:flutter/material.dart';

import 'package:curejobs/app/theme/app_colors.dart';

import 'verification_note.dart';

/// Green "<plan> plan active · until <date>" note at the top of the
/// documents step, confirming the purchase that unlocked verification.
class PlanActiveNote extends StatelessWidget {
  const PlanActiveNote({super.key, this.planName, this.activeUntil});

  final String? planName;
  final String? activeUntil;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: VerificationNote(
        icon: Icons.check_circle_outline_rounded,
        text: activeUntil == null
            ? '${planName ?? 'Your'} plan active'
            : '${planName ?? 'Your'} plan active · until $activeUntil',
        color: isDark ? AppColors.successDark : const Color(0xFF166534),
        background: isDark
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.successLight,
      ),
    );
  }
}
