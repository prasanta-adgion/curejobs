import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/job_application.dart';

export '../../domain/entities/job_application.dart';

class StatusColors {
  const StatusColors({required this.fg, required this.bg});
  final Color fg;
  final Color bg;
}

/// Status colors from [AppColors], for light and dark themes.
extension ApplicationStatusColors on ApplicationStatus {
  StatusColors colors(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    StatusColors tinted(Color light, Color darkFg, Color lightBg) =>
        dark
            ? StatusColors(fg: darkFg, bg: darkFg.withValues(alpha: 0.16))
            : StatusColors(fg: light, bg: lightBg);

    return switch (this) {
      ApplicationStatus.applied => tinted(
        AppColors.info,
        AppColors.infoDark,
        AppColors.infoLight,
      ),
      ApplicationStatus.underReview => tinted(
        const Color(0xFFB45309),
        AppColors.warningDark,
        AppColors.warningLight,
      ),
      ApplicationStatus.shortlisted => tinted(
        AppColors.primary,
        AppColors.darkPrimary,
        AppColors.primaryLight,
      ),
      ApplicationStatus.selected => tinted(
        AppColors.success,
        AppColors.successDark,
        AppColors.successLight,
      ),
      ApplicationStatus.rejected => tinted(
        const Color(0xFFDC2626),
        AppColors.errorDark,
        AppColors.errorLight,
      ),
      ApplicationStatus.withdrawn => StatusColors(
        fg: theme.colorScheme.onSurfaceVariant,
        bg: dark
            ? AppColors.darkSurfaceSecondary
            : AppColors.lightSurfaceSecondary,
      ),
    };
  }
}
