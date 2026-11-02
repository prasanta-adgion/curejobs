import 'package:flutter/material.dart';

import 'app_fonts.dart';

abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    headlineLarge: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    titleLarge: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    titleMedium: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    labelMedium: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontFamily: AppFonts.primary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),
  );
}
