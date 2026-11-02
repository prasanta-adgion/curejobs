import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(isDark: false);

  static ThemeData get dark => _build(isDark: true);

  static ThemeData _build({required bool isDark}) {
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final primary = isDark ? AppColors.darkPrimary : AppColors.primary;

    final background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final inputBackground = isDark
        ? AppColors.darkInputBackground
        : AppColors.lightInputBackground;

    final placeholder = isDark
        ? AppColors.darkPlaceholder
        : AppColors.lightPlaceholder;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: isDark ? AppColors.darkBackground : AppColors.white,
          primaryContainer: isDark
              ? AppColors.darkPrimaryContainer
              : AppColors.primaryLight,
          onPrimaryContainer: isDark
              ? AppColors.darkTextPrimary
              : AppColors.primaryDark,
          surface: surface,
          onSurface: textColor,
          onSurfaceVariant: secondaryText,
          outline: border,
          outlineVariant: border,
          error: isDark ? AppColors.errorDark : AppColors.error,
          onError: isDark ? AppColors.darkBackground : AppColors.white,
        );

    final textTheme = AppTypography.textTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    OutlineInputBorder inputBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,

      scaffoldBackgroundColor: background,

      // ───────────────────────────────
      // TYPOGRAPHY
      // ───────────────────────────────
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // ───────────────────────────────
      // APP BAR
      // ───────────────────────────────
      appBarTheme: AppBarThemeData(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: textColor, size: 24),
      ),

      // ───────────────────────────────
      // CARDS
      // ───────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: border),
        ),
      ),

      // ───────────────────────────────
      // FILLED BUTTON
      // ───────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: isDark
              ? AppColors.darkButtonDisabled
              : AppColors.lightButtonDisabled,
          disabledForegroundColor: isDark
              ? AppColors.darkButtonDisabledText
              : AppColors.lightButtonDisabledText,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),

      // ───────────────────────────────
      // ELEVATED BUTTON
      // ───────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),

      // ───────────────────────────────
      // OUTLINED BUTTON
      // ───────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: border),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),

      // ───────────────────────────────
      // TEXT BUTTON
      // ───────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelMedium,
        ),
      ),

      // ───────────────────────────────
      // INPUT FIELDS
      // ───────────────────────────────
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: placeholder),
        labelStyle: textTheme.bodyMedium?.copyWith(color: secondaryText),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: primary),
        prefixIconColor: secondaryText,
        suffixIconColor: secondaryText,
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, width: 1.5),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, width: 1.5),
        disabledBorder: inputBorder(border),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      ),

      // ───────────────────────────────
      // NAVIGATION BAR
      // ───────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 72,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? primary
                : secondaryText,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? primary
                : secondaryText,
          ),
        ),
      ),

      // ───────────────────────────────
      // FLOATING ACTION BUTTON
      // ───────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
      ),

      // ───────────────────────────────
      // CHECKBOX
      // ───────────────────────────────
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      ),

      // ───────────────────────────────
      // SWITCH
      // ───────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
      ),

      // ───────────────────────────────
      // PROGRESS INDICATORS
      // ───────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: scheme.primaryContainer,
      ),

      // ───────────────────────────────
      // DIVIDER
      // ───────────────────────────────
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      // ───────────────────────────────
      // DIALOG
      // ───────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        ),
      ),

      // ───────────────────────────────
      // BOTTOM SHEET
      // ───────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ───────────────────────────────
      // SNACKBAR
      // ───────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AppColors.darkSurfaceSecondary
            : AppColors.logoNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),

      // ───────────────────────────────
      // LIST TILES
      // ───────────────────────────────
      listTileTheme: ListTileThemeData(
        iconColor: secondaryText,
        textColor: textColor,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(color: secondaryText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),

      // ───────────────────────────────
      // TEXT SELECTION
      // ───────────────────────────────
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withValues(alpha: 0.20),
        selectionHandleColor: primary,
      ),
    );
  }
}
