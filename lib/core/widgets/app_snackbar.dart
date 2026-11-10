import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum AppSnackbarType { success, error, info }

/// Global snackbar used across the app for success, error and info messages.
///
/// Register [messengerKey] once on `MaterialApp.scaffoldMessengerKey`, then
/// call from anywhere (pages, cubits, services) without a BuildContext:
///
/// ```dart
/// AppSnackbar.success(title: 'Profile updated');
/// AppSnackbar.error(title: "Couldn't verify code",
///     message: 'The OTP is incorrect or expired.',
///     actionLabel: 'Resend code', onAction: _resend);
/// ```
abstract final class AppSnackbar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static const _defaultDuration = Duration(seconds: 4);

  static void success({
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) => show(
    type: AppSnackbarType.success,
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
  );

  static void error({
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) => show(
    type: AppSnackbarType.error,
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
  );

  static void info({
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) => show(
    type: AppSnackbarType.info,
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
  );

  static void hide() => messengerKey.currentState?.hideCurrentSnackBar();

  static void show({
    required AppSnackbarType type,
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = _defaultDuration,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: duration,
          dismissDirection: DismissDirection.horizontal,
          content: _AppSnackbarCard(
            type: type,
            title: title,
            message: message,
            actionLabel: actionLabel,
            duration: duration,
            onAction: onAction == null
                ? null
                : () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
            onClose: messenger.hideCurrentSnackBar,
          ),
        ),
      );
  }
}

class _AppSnackbarCard extends StatelessWidget {
  const _AppSnackbarCard({
    required this.type,
    required this.title,
    required this.duration,
    required this.onClose,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final AppSnackbarType type;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onClose;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accent = switch (type) {
      AppSnackbarType.success => isDark ? AppColors.successDark : AppColors.success,
      AppSnackbarType.error => isDark ? AppColors.errorDark : AppColors.error,
      AppSnackbarType.info => isDark ? AppColors.infoDark : AppColors.info,
    };
    final track = isDark
        ? AppColors.darkSurfaceSecondary
        : switch (type) {
            AppSnackbarType.success => AppColors.successLight,
            AppSnackbarType.error => AppColors.errorLight,
            AppSnackbarType.info => AppColors.infoLight,
          };
    final icon = switch (type) {
      AppSnackbarType.success => Icons.check_rounded,
      AppSnackbarType.error => Icons.priority_high_rounded,
      AppSnackbarType.info => Icons.info_outline_rounded,
    };

    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightBorder;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bodyColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final closeColor = isDark ? AppColors.darkTextDisabled : AppColors.lightTextTertiary;
    final actionColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final onAccent = isDark ? AppColors.darkBackground : AppColors.white;

    final hasAction = actionLabel != null && onAction != null;

    return Semantics(
      liveRegion: true,
      container: true,
      label: message == null ? title : '$title. $message',
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 6, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                    child: Icon(icon, size: 18, color: onAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                          if (message != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              message!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: bodyColor,
                                fontSize: 12.5,
                                height: 1.45,
                              ),
                            ),
                          ],
                          if (hasAction) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _TextAction(
                                  label: actionLabel!,
                                  color: actionColor,
                                  bold: true,
                                  onTap: onAction!,
                                ),
                                const SizedBox(width: 16),
                                _TextAction(
                                  label: 'Dismiss',
                                  color: bodyColor,
                                  onTap: onClose,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!hasAction)
                    IconButton(
                      onPressed: onClose,
                      tooltip: 'Close',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.close_rounded, size: 18, color: closeColor),
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: duration,
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 3,
                color: accent,
                backgroundColor: track,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.bold = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontSize: 12.5,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
