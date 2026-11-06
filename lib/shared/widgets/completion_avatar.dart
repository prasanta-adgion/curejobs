import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Photo or initials avatar wrapped in a profile-completion ring, with a percent tag
/// on the bottom edge. At 100% the ring closes and the tag becomes a green
/// tick. Designed for the navy headers, so colours are fixed.
class CompletionAvatar extends StatelessWidget {
  const CompletionAvatar({
    super.key,
    required this.initials,
    required this.percent,
    this.photoUrl,
    this.size = 52,
    this.longLabel = false,
    this.onTap,
    this.topRightBadge,
  });

  /// Null while the profile is loading; shows a person icon.
  final String? initials;

  /// Shown over the initials, which remain while it loads, if it is null,
  /// or if it fails.
  final String? photoUrl;

  /// 0 to 100, or null while loading (draws an empty ring, no tag).
  final int? percent;

  /// Outer size including the ring.
  final double size;

  /// "75% complete" instead of "75%". Use on larger avatars.
  final bool longLabel;
  final VoidCallback? onTap;

  /// Optional small badge in the top-right corner, such as a camera button.
  final Widget? topRightBadge;

  static const _background = AppColors.logoNavy;
  static const _track = AppColors.darkInputBorder;

  Color get _progressColor {
    final value = percent ?? 0;
    if (value >= 50) return AppColors.darkPrimary;
    return AppColors.warning;
  }

  Color get _tagColor {
    final value = percent ?? 0;
    if (value >= 50) return AppColors.primary;
    return const Color(0xFFB45309);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = percent?.clamp(0, 100);
    final complete = value != null && value >= 100;
    final stroke = size >= 70 ? 4.0 : 3.0;
    // A navy gap between ring and avatar keeps the two from blending.
    final inner = size - stroke * 2 - 4;

    final semantics = value == null
        ? 'Your profile'
        : 'Your profile, $value percent complete';

    final Widget fallback = initials == null
        ? Icon(
            Icons.person_outline_rounded,
            size: inner * 0.45,
            color: AppColors.primaryLight,
          )
        : Text(
            initials!,
            style:
                (size >= 70
                        ? theme.textTheme.titleLarge
                        : theme.textTheme.labelLarge)
                    ?.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
          );

    return Semantics(
      button: onTap != null,
      label: semantics,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(
                  progress: (value ?? 0) / 100,
                  color: complete ? AppColors.primary : _progressColor,
                  track: _track,
                  stroke: stroke,
                ),
              ),
              Container(
                width: inner,
                height: inner,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkPrimaryContainer,
                ),
                child: photoUrl == null
                    ? fallback
                    : Image.network(
                        photoUrl!,
                        width: inner,
                        height: inner,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, wasSync) =>
                            wasSync || frame != null ? child : fallback,
                        errorBuilder: (context, error, stackTrace) => fallback,
                      ),
              ),
              if (value != null && !complete)
                Positioned(
                  bottom: -9,
                  child: _Tag(
                    label: longLabel ? '$value% complete' : '$value%',
                    color: _tagColor,
                  ),
                ),
              if (complete)
                Positioned(
                  right: size >= 70 ? 2 : -2,
                  bottom: size >= 70 ? 2 : -2,
                  child: const _Tick(),
                ),
              if (topRightBadge != null)
                Positioned(
                  right: size >= 70 ? 0 : -4,
                  top: size >= 70 ? 2 : -4,
                  child: topRightBadge!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CompletionAvatar._background, width: 2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.success,
        border: Border.all(color: CompletionAvatar._background, width: 2),
      ),
      child: const Icon(Icons.check_rounded, size: 11, color: AppColors.white),
    );
  }
}

/// Grey track with a rounded arc drawn clockwise from 12 o'clock.
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, paint..color = track);
    if (progress <= 0) return;

    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      paint
        ..color = color
        ..strokeCap = progress >= 1 ? StrokeCap.butt : StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
