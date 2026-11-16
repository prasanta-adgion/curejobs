import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';

/// Small stylised first page of a CV, so each card reads as a document at a
/// glance.
class CvThumbnail extends StatelessWidget {
  const CvThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget line(double? width, Color color, {double height = 2}) => Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );

    return Container(
      width: 52,
      height: 68,
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line(26, AppColors.logoNavy, height: 4),
          line(20, AppColors.primary, height: 2.5),
          const SizedBox(height: 2),
          line(null, AppColors.lightBorder),
          line(null, AppColors.lightBorder),
          line(28, AppColors.lightBorder),
          const SizedBox(height: 2),
          line(18, AppColors.primary, height: 2.5),
          line(null, AppColors.lightBorder),
        ],
      ),
    );
  }
}
