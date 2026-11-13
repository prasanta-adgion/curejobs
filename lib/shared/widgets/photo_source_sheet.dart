import 'dart:math' as math;

import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// What the user chose in the photo sheet.
enum PhotoSheetAction { camera, gallery, remove }

/// Asks where the profile photo should come from. With a [photo] or
/// [initials] the sheet offers to replace it, and to remove it when
/// [canRemove] is true. Returns null if dismissed.
Future<PhotoSheetAction?> showPhotoSourceSheet(
  BuildContext context, {
  ImageProvider? photo,
  String? initials,
  bool canRemove = false,
}) {
  return showModalBottomSheet<PhotoSheetAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    elevation: 0,
    builder: (_) => _PhotoSourceSheet(
      photo: photo,
      initials: initials,
      canRemove: canRemove,
    ),
  );
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet({this.photo, this.initials, required this.canRemove});

  final ImageProvider? photo;
  final String? initials;
  final bool canRemove;

  static const _portraitSize = 92.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasPhoto = canRemove;

    void close({required PhotoSheetAction action}) =>
        Navigator.of(context).pop(action);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: _portraitSize / 2),
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 58, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasPhoto
                        ? 'Update your photo'
                        : 'Put a face to your profile',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasPhoto
                        ? 'Keep it clear and recent.'
                        : 'Recruiters notice profiles with a photo.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _SourceTile(
                            icon: Icons.photo_camera_outlined,
                            title: 'Take photo',
                            subtitle: 'Use your camera',
                            background: isDark
                                ? AppColors.primary
                                : AppColors.logoNavy,
                            foreground: AppColors.white,
                            iconColor: isDark
                                ? AppColors.white
                                : AppColors.darkPrimary,
                            subtitleColor: isDark
                                ? AppColors.primaryLight
                                : AppColors.darkTextSecondary,
                            onTap: () => close(action: PhotoSheetAction.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SourceTile(
                            icon: Icons.photo_library_outlined,
                            title: 'Gallery',
                            subtitle: 'PNG, JPG or WEBP',
                            foreground: scheme.onSurface,
                            iconColor: scheme.primary,
                            subtitleColor: scheme.onSurfaceVariant,
                            borderColor: scheme.outlineVariant,
                            onTap: () =>
                                close(action: PhotoSheetAction.gallery),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (hasPhoto)
                    TextButton.icon(
                      onPressed: () => close(action: PhotoSheetAction.remove),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.error,
                      ),
                      icon: const Icon(AppIcons.delete, size: 18),
                      label: const Text('Remove photo'),
                    )
                  else
                    const _PhotoTips(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: _portraitSize / 2 + 8,
          right: 8,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
            color: scheme.onSurfaceVariant,
            icon: const Icon(AppIcons.close, size: 20),
          ),
        ),
        _Portrait(
          size: _portraitSize,
          photo: photo,
          initials: initials,
          showGuide: !hasPhoto,
        ),
      ],
    );
  }
}

/// Circle on the sheet's top edge, cut out from the page by a surface ring.
class _Portrait extends StatelessWidget {
  const _Portrait({
    required this.size,
    required this.showGuide,
    this.photo,
    this.initials,
  });

  final double size;
  final bool showGuide;
  final ImageProvider? photo;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = theme.brightness == Brightness.dark
        ? AppColors.darkPrimary
        : AppColors.secondary;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
      child: CustomPaint(
        painter: showGuide ? _DashedCirclePainter(accent) : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primaryContainer,
            border: showGuide ? null : Border.all(color: accent, width: 2),
            image: photo == null
                ? null
                : DecorationImage(image: photo!, fit: BoxFit.cover),
          ),
          child: photo != null
              ? null
              : showGuide || initials == null
              ? Icon(
                  Icons.person_outline_rounded,
                  size: 32,
                  color: scheme.onPrimaryContainer,
                )
              : Text(
                  initials!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.foreground,
    required this.iconColor,
    required this.subtitleColor,
    required this.onTap,
    this.background = AppColors.transparent,
    this.borderColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color foreground;
  final Color iconColor;
  final Color subtitleColor;
  final Color background;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: borderColor == null
            ? BorderSide.none
            : BorderSide(color: borderColor!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(height: 22),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoTips extends StatelessWidget {
  const _PhotoTips();

  static const _tips = ['Face centred', 'Good light', 'Plain background'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tick = theme.brightness == Brightness.dark
        ? AppColors.successDark
        : AppColors.success;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final tip in _tips)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 14, color: tick),
              const SizedBox(width: 4),
              Text(
                tip,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter(this.color);

  final Color color;

  static const _dashes = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    final step = 2 * math.pi / _dashes;

    for (var i = 0; i < _dashes; i++) {
      canvas.drawArc(rect.deflate(1), i * step, step * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
