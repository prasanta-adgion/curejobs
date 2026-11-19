import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

/// Single search field on the navy dashboard header. It isn't editable here:
/// tapping it opens the search screen, so the box is always white with
/// dark text.
class DashboardSearchBar extends StatelessWidget {
  const DashboardSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Search jobs',
      excludeSemantics: true,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Job title, skill or hospital',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.lightIconSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
