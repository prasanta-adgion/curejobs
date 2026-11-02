import 'package:flutter/material.dart';

abstract final class AppColors {
  // ───────────────────────────────
  // BRAND
  // ───────────────────────────────

  static const primary = Color(0xFF5145D9);
  static const primaryDark = Color(0xFF4035B8);
  static const primaryLight = Color(0xFFEEF0FF);
  static const secondary = Color(0xFF766BF0);

  static const logoNavy = Color(0xFF141529);
  static const logoViolet = Color(0xFF5145D9);

  // Dark theme brand
  static const darkPrimary = Color(0xFFA69EFF);
  static const darkPrimaryContainer = Color(0xFF30295C);

  // ───────────────────────────────
  // BASIC
  // ───────────────────────────────

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);

  // ───────────────────────────────
  // LIGHT THEME
  // ───────────────────────────────

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceSecondary = Color(0xFFF1F5F9);
  static const lightSurfaceVariant = Color(0xFFEEF0FF);

  static const lightTextPrimary = Color(0xFF141529);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextTertiary = Color(0xFF94A3B8);
  static const lightTextDisabled = Color(0xFFCBD5E1);

  static const lightInputBackground = Color(0xFFFFFFFF);
  static const lightInputBorder = Color(0xFFE2E8F0);
  static const lightPlaceholder = Color(0xFF64748B);

  static const lightBorder = Color(0xFFE2E8F0);
  static const lightDivider = Color(0xFFE5E7EB);

  static const lightIconPrimary = Color(0xFF141529);
  static const lightIconSecondary = Color(0xFF64748B);

  static const lightButtonDisabled = Color(0xFFE2E8F0);
  static const lightButtonDisabledText = Color(0xFF64748B);

  static const lightShimmerBase = Color(0xFFE2E8F0);
  static const lightShimmerHighlight = Color(0xFFF8FAFC);

  // ───────────────────────────────
  // DARK THEME
  // ───────────────────────────────

  static const darkBackground = Color(0xFF0D1020);
  static const darkSurface = Color(0xFF191E32);
  static const darkSurfaceSecondary = Color(0xFF22283D);
  static const darkSurfaceVariant = Color(0xFF30295C);

  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFA5AEC4);
  static const darkTextTertiary = Color(0xFF9AA5BB);
  static const darkTextDisabled = Color(0xFF7D879C);

  static const darkInputBackground = Color(0xFF191E32);
  static const darkInputBorder = Color(0xFF30364B);
  static const darkPlaceholder = Color(0xFFA5AEC4);

  static const darkBorder = Color(0xFF30364B);
  static const darkDivider = Color(0xFF30364B);

  static const darkIconPrimary = Color(0xFFF8FAFC);
  static const darkIconSecondary = Color(0xFFA5AEC4);

  static const darkButtonDisabled = Color(0xFF30364B);
  static const darkButtonDisabledText = Color(0xFF9AA5BB);

  static const darkShimmerBase = Color(0xFF22283D);
  static const darkShimmerHighlight = Color(0xFF30364B);

  // ───────────────────────────────
  // SEMANTIC
  // ───────────────────────────────

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF4ADE80);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const errorDark = Color(0xFFF87171);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFFFBBF24);

  static const info = Color(0xFF2563EB);
  static const infoLight = Color(0xFFDBEAFE);
  static const infoDark = Color(0xFF60A5FA);

  // ───────────────────────────────
  // JOB APPLICATION STATUS
  // ───────────────────────────────

  static const jobApplied = info;
  static const jobShortlisted = primary;
  static const jobInterview = warning;
  static const jobSelected = success;
  static const jobRejected = error;

  // ───────────────────────────────
  // OTHER
  // ───────────────────────────────

  static const favorite = Color(0xFFEF4444);
  static const rating = Color(0xFFF59E0B);
  static const verified = Color(0xFF16A34A);

  static const lightOverlay = Color(0x80000000);
  static const darkOverlay = Color(0xB3000000);

  static const lightShadow = Color(0x14000000);
  static const darkShadow = Color(0x66000000);
}
