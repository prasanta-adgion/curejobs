import 'package:flutter/material.dart';

/// Full-width "+ Add …" button: soft tinted fill with a dashed outline.
///
/// - default: one line, for "Add more".
/// - [AlertAddButton.large]: taller, with an icon and a hint line, for the
///   first pick.
/// - [AlertAddButton.locked]: grey with a lock, not tappable.
class AlertAddButton extends StatelessWidget {
  const AlertAddButton({super.key, required this.label, required this.onTap})
    : hint = null,
      large = false;

  const AlertAddButton.large({
    super.key,
    required this.label,
    required this.onTap,
    this.hint,
  }) : large = true;

  const AlertAddButton.locked({super.key, required this.label})
    : onTap = null,
      hint = null,
      large = false;

  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    final color = enabled ? scheme.primary : scheme.outline;
    final radius = BorderRadius.circular(12);

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (enabled ? theme.textTheme.labelLarge : theme.textTheme.bodySmall)
          ?.copyWith(
            color: enabled ? color : scheme.onSurfaceVariant,
            fontWeight: enabled ? FontWeight.w600 : null,
          ),
    );

    final content = large
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 22, color: color),
              const SizedBox(height: 4),
              text,
              if (hint != null) ...[
                const SizedBox(height: 2),
                Text(
                  hint!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enabled ? Icons.add_rounded : Icons.lock_outline_rounded,
                size: enabled ? 18 : 15,
                color: color,
              ),
              const SizedBox(width: 6),
              Flexible(child: text),
            ],
          );

    return Material(
      color: enabled
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: enabled
                ? color.withValues(alpha: 0.7)
                : scheme.outlineVariant,
            radius: 12,
          ),
          child: Container(
            constraints: BoxConstraints(minHeight: large ? 76 : 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Dashed rounded-rectangle outline.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final r = radius.clamp(0, size.height / 2).toDouble();
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.6),
          Radius.circular(r),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
