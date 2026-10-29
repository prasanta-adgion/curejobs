import 'dart:ui';

abstract final class AppColors {
  AppColors._();

  // ─────────────────────────────────
  // BRAND COLORS (CureJobs)
  // ─────────────────────────────────

  static const Color primary = Color(0xFF5145D9);
  static const Color primaryDark = Color(0xFF4035B8);
  static const Color primaryLight = Color(0xFFEEF0FF);
  static const Color secondary = Color(0xFF766BF0);

  // Logo colors
  static const Color logoNavy = Color(0xFF141529);
  static const Color logoViolet = Color(0xFF5145D9);

  // ─────────────────────────────────
  // BASIC COLORS
  // ─────────────────────────────────

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ─────────────────────────────────
  // BACKGROUND & SURFACE
  // ─────────────────────────────────

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);
  static const Color surfaceVariant = Color(0xFFEEF0FF);

  // ─────────────────────────────────
  // TEXT COLORS
  // ─────────────────────────────────

  static const Color textPrimary = Color(0xFF141529);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF5145D9);

  // ─────────────────────────────────
  // INPUT & FORM COLORS
  // ─────────────────────────────────

  static const Color placeholder = Color(0xFF94A3B8);
  static const Color inputBackground = Color(0xFFF8FAFC);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputFocusedBorder = primary;
  static const Color inputErrorBorder = Color(0xFFEF4444);

  // ─────────────────────────────────
  // BORDER & DIVIDER
  // ─────────────────────────────────

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE5E7EB);

  // ─────────────────────────────────
  // SEMANTIC / STATUS COLORS
  // ─────────────────────────────────

  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─────────────────────────────────
  // BUTTON COLORS
  // ─────────────────────────────────

  static const Color buttonPrimary = primary;
  static const Color buttonPressed = primaryDark;
  static const Color buttonDisabled = Color(0xFFE2E8F0);
  static const Color buttonText = white;

  // ─────────────────────────────────
  // ICON COLORS
  // ─────────────────────────────────

  static const Color iconPrimary = Color(0xFF141529);
  static const Color iconSecondary = Color(0xFF64748B);
  static const Color iconActive = primary;
  static const Color iconDisabled = Color(0xFFCBD5E1);

  // ─────────────────────────────────
  // JOB APPLICATION STATUS
  // ─────────────────────────────────

  static const Color jobApplied = Color(0xFF2563EB);
  static const Color jobShortlisted = Color(0xFF5145D9);
  static const Color jobInterview = Color(0xFFF59E0B);
  static const Color jobSelected = Color(0xFF16A34A);
  static const Color jobRejected = Color(0xFFEF4444);

  // ─────────────────────────────────
  // EXTRA UI COLORS
  // ─────────────────────────────────

  static const Color favorite = Color(0xFFEF4444);
  static const Color rating = Color(0xFFF59E0B);
  static const Color verified = Color(0xFF16A34A);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // ─────────────────────────────────
  // OVERLAY & SHADOW
  // ─────────────────────────────────

  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x14000000);
}
