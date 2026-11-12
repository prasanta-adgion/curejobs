import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum AppSnackbarType { success, error, info }

abstract final class AppSnackbar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static const _defaultDuration = Duration(seconds: 4);

  /// Longer when there's a button, so there's time to tap Undo or Retry.
  static const _actionDuration = Duration(seconds: 6);

  static void success({
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    bool compact = false,
    Duration? duration,
    ScaffoldMessengerState? messenger,
  }) => show(
    type: AppSnackbarType.success,
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    icon: icon,
    compact: compact,
    duration: duration,
    messenger: messenger,
  );

  static void error({
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    bool compact = false,
    Duration? duration,
    ScaffoldMessengerState? messenger,
  }) => show(
    type: AppSnackbarType.error,
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    icon: icon,
    compact: compact,
    duration: duration,
    messenger: messenger,
  );

  static void info({
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    bool compact = false,
    Duration? duration,
    ScaffoldMessengerState? messenger,
  }) => show(
    type: AppSnackbarType.info,
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
    icon: icon,
    compact: compact,
    duration: duration,
    messenger: messenger,
  );

  static void hide() => messengerKey.currentState?.hideCurrentSnackBar();

  /// Shows the snackbar on the app-wide messenger, or on [messenger] when
  /// given. Pass a local one from inside a modal bottom sheet or dialog: the
  /// app-wide snackbar is drawn under the modal, where the user can't see it.
  ///
  /// [icon] replaces the type's default icon. [compact] shows a small
  /// centred pill for one- or two-word confirmations; it ignores [message]
  /// and the action. [duration] defaults to 4 seconds, or 6 with an action.
  static void show({
    required AppSnackbarType type,
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    bool compact = false,
    Duration? duration,
    ScaffoldMessengerState? messenger,
  }) {
    final target = messenger ?? messengerKey.currentState;
    if (target == null) return;

    final hasAction = !compact && actionLabel != null && onAction != null;
    final shownFor =
        duration ?? (hasAction ? _actionDuration : _defaultDuration);

    target
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: shownFor,
          dismissDirection: DismissDirection.horizontal,
          content: compact
              ? _CompactPill(type: type, title: title, icon: icon)
              : _SnackbarCard(
                  type: type,
                  title: title,
                  message: message,
                  icon: icon,
                  actionLabel: hasAction ? actionLabel : null,
                  duration: shownFor,
                  onAction: hasAction
                      ? () {
                          target.hideCurrentSnackBar();
                          onAction();
                        }
                      : null,
                  onClose: target.hideCurrentSnackBar,
                ),
        ),
      );
  }
}

/// Colours shared by the card and the pill. The surface is navy in both
/// themes so the message stands out from the page.
class _Palette {
  _Palette(BuildContext context, AppSnackbarType type)
    : isDark = Theme.of(context).brightness == Brightness.dark,
      accent = switch (type) {
        AppSnackbarType.success => AppColors.successDark,
        AppSnackbarType.error => AppColors.errorDark,
        AppSnackbarType.info => AppColors.infoDark,
      },
      icon = switch (type) {
        AppSnackbarType.success => Icons.check_circle_outline_rounded,
        AppSnackbarType.error => Icons.warning_amber_rounded,
        AppSnackbarType.info => Icons.info_outline_rounded,
      };

  final bool isDark;
  final Color accent;
  final IconData icon;

  // A lighter navy with a border in dark mode, so it still lifts off the
  // dark page.
  Color get surface => isDark ? AppColors.darkSurface : AppColors.logoNavy;
  Color? get border => isDark ? _line : null;
  Color get title => AppColors.white;
  Color get body => const Color(0xFFA3A8C3);
  Color get track => _line;
  Color get shadow => isDark ? AppColors.darkShadow : const Color(0x33141529);

  static const _line = Color(0xFF2B2E4A);
}

class _SnackbarCard extends StatelessWidget {
  const _SnackbarCard({
    required this.type,
    required this.title,
    required this.duration,
    required this.onClose,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final AppSnackbarType type;
  final String title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onClose;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _Palette(context, type);
    final hasMessage = message != null && message!.isNotEmpty;

    // With a message the button sits under the text; without one it fits
    // on the same row.
    final actionButton = actionLabel != null && onAction != null
        ? _ActionButton(
            label: actionLabel!,
            color: palette.accent,
            onTap: onAction!,
          )
        : null;

    return Semantics(
      liveRegion: true,
      container: true,
      label: hasMessage ? '$title. $message' : title,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: palette.border == null
              ? null
              : Border.all(color: palette.border!),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: hasMessage
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon ?? palette.icon,
                size: 19,
                color: palette.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: hasMessage ? 1 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: palette.title,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                    ),
                    if (hasMessage) ...[
                      const SizedBox(height: 2),
                      Text(
                        message!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.body,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      if (actionButton != null) ...[
                        const SizedBox(height: 8),
                        actionButton,
                      ],
                    ],
                  ],
                ),
              ),
            ),
            if (!hasMessage && actionButton != null) ...[
              const SizedBox(width: 8),
              actionButton,
            ],
            const SizedBox(width: 4),
            _CountdownClose(
              duration: duration,
              color: palette.accent,
              track: palette.track,
              iconColor: palette.body,
              onTap: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.logoNavy,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Close button with a ring that empties over [duration].
class _CountdownClose extends StatelessWidget {
  const _CountdownClose({
    required this.duration,
    required this.color,
    required this.track,
    required this.iconColor,
    required this.onTap,
  });

  final Duration duration;
  final Color color;
  final Color track;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox.square(
          dimension: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 28,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: 0),
                  duration: duration,
                  builder: (_, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 2,
                    strokeCap: StrokeCap.round,
                    color: color,
                    backgroundColor: track,
                  ),
                ),
              ),
              Icon(Icons.close_rounded, size: 14, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small centred pill for very short confirmations, like "Copied".
class _CompactPill extends StatelessWidget {
  const _CompactPill({required this.type, required this.title, this.icon});

  final AppSnackbarType type;
  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = _Palette(context, type);
    final pillIcon =
        icon ??
        switch (type) {
          AppSnackbarType.success => Icons.check_rounded,
          AppSnackbarType.error => Icons.priority_high_rounded,
          AppSnackbarType.info => Icons.info_outline_rounded,
        };

    return Semantics(
      liveRegion: true,
      label: title,
      child: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(999),
            border: palette.border == null
                ? null
                : Border.all(color: palette.border!),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(pillIcon, size: 14, color: palette.accent),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: palette.title,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
