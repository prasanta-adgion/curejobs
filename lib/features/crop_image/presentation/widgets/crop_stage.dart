import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../models/crop_transform.dart';

/// The photo behind a round frame. Drag to move and pinch to zoom.
class CropStage extends StatefulWidget {
  const CropStage({
    super.key,
    required this.image,
    required this.transform,
    required this.onChanged,
  });

  final ui.Image image;
  final CropTransform transform;
  final ValueChanged<CropTransform> onChanged;

  @override
  State<CropStage> createState() => _CropStageState();
}

class _CropStageState extends State<CropStage> {
  static const _margin = 24.0;

  double _startZoom = CropTransform.minZoom;

  void _onUpdate(ScaleUpdateDetails details, double frame) {
    final current = widget.transform;
    widget.onChanged(
      current
          .copyWith(
            zoom: (_startZoom * details.scale).clamp(
              CropTransform.minZoom,
              CropTransform.maxZoom,
            ),
            offset: current.offset + details.focalPointDelta / frame,
          )
          .clampedTo(widget.image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frame =
            math.min(constraints.maxWidth, constraints.maxHeight) - _margin * 2;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (_) => _startZoom = widget.transform.zoom,
          onScaleUpdate: (details) => _onUpdate(details, frame),
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _CropPainter(
                    image: widget.image,
                    transform: widget.transform,
                    frame: frame,
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: Center(child: _GestureHint()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GestureHint extends StatelessWidget {
  const _GestureHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.open_with_rounded,
            size: 15,
            color: AppColors.darkTextPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            'Drag to move, pinch to zoom',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.darkTextPrimary),
          ),
        ],
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  const _CropPainter({
    required this.image,
    required this.transform,
    required this.frame,
  });

  final ui.Image image;
  final CropTransform transform;
  final double frame;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final circle = Rect.fromCircle(center: centre, radius: frame / 2);

    transform.paint(canvas, image, frame: frame, centre: centre);

    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addOval(circle),
      Paint()..color = AppColors.darkBackground.withValues(alpha: 0.68),
    );

    final grid = Paint()
      ..color = AppColors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas
      ..save()
      ..clipPath(Path()..addOval(circle));
    for (final third in [1 / 3, 2 / 3]) {
      final x = circle.left + frame * third;
      final y = circle.top + frame * third;
      canvas
        ..drawLine(Offset(x, circle.top), Offset(x, circle.bottom), grid)
        ..drawLine(Offset(circle.left, y), Offset(circle.right, y), grid);
    }
    canvas
      ..restore()
      ..drawOval(
        circle,
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.image != image || old.transform != transform || old.frame != frame;
}
