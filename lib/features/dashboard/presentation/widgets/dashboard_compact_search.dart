import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'dashboard_header.dart';

/// Slim navy bar pinned to the top once the full header scrolls away. Shows
/// the current search and takes the user back to the search fields.
class DashboardCompactSearch extends StatelessWidget {
  const DashboardCompactSearch({super.key, required this.summary, this.onTap});

  final String summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(10);

    return ColoredBox(
      color: DashboardHeader.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Material(
            color: AppColors.darkSurface,
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.darkPrimary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: DashboardHeader.muted,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
