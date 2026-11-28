import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

extension ThemeContextExtension on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Green for "Paid", "Active" and ticks, readable in both themes.
  Color get successColor =>
      isDarkMode ? AppColors.successDark : AppColors.success;

  /// Soft green behind [successColor] text.
  Color get successContainer => isDarkMode
      ? AppColors.successDark.withValues(alpha: 0.16)
      : AppColors.successLight;
}
