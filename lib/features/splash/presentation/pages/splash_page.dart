import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// First screen of the app: an ECG line draws in and turns into a job-search
/// lens, surrounded by healthcare role chips. Calls [onFinished] when done.
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 3000),
  });

  final VoidCallback onFinished;
  final Duration duration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _pulse;

  late final Animation<double> _line;
  late final Animation<double> _lens;
  late final Animation<double> _chips;
  late final Animation<double> _text;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: widget.duration);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _line = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _lens = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.38, 0.6, curve: Curves.easeOutBack),
    );
    _chips = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
    );
    _text = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 0.7, curve: Curves.easeOut),
    );

    _intro.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 240,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_intro, _pulse]),
                        builder: (context, _) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _HeartbeatLensPainter(
                                  line: _line.value,
                                  lens: _lens.value,
                                  pulse: _pulse.value,
                                ),
                              ),
                            ),
                            ..._buildChips(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _text,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(_text),
                        child: const _BrandText(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 28),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _intro,
                    builder: (context, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _intro.value,
                        minHeight: 3,
                        backgroundColor: AppColors.primaryLight,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _TrustItem(
                        icon: Icons.verified_outlined,
                        label: 'Verified employers',
                      ),
                      _TrustItem(
                        icon: Icons.lock_outline,
                        label: 'Free and secure',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChips() {
    const chips = [
      (label: 'Nurse', left: 14.0, top: 26.0),
      (label: 'Doctor', left: 214.0, top: 40.0),
      (label: 'Pharmacist', left: 6.0, top: 180.0),
      (label: 'Lab tech', left: 210.0, top: 190.0),
    ];
    return [
      for (final (i, chip) in chips.indexed)
        Positioned(
          left: chip.left,
          top: chip.top,
          child: Opacity(
            opacity: _chips.value,
            child: Transform.translate(
              // Gentle float, offset per chip so they don't move in sync.
              offset: Offset(
                0,
                (1 - _chips.value) * 10 +
                    math.sin((_pulse.value + i * 0.25) * 2 * math.pi) * 2,
              ),
              child: _RoleChip(label: chip.label),
            ),
          ),
        ),
    ];
  }
}

class _HeartbeatLensPainter extends CustomPainter {
  _HeartbeatLensPainter({
    required this.line,
    required this.lens,
    required this.pulse,
  });

  final double line;
  final double lens;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(
      center,
      78,
      Paint()..color = AppColors.primaryLight,
    );

    if (lens > 0) {
      canvas.drawCircle(
        center,
        46 + 32 * pulse,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.secondary.withValues(alpha: 0.5 * (1 - pulse)),
      );
    }

    // ECG trace running in from the left edge into the lens.
    final cy = center.dy;
    final ecg = Path()
      ..moveTo(14, cy)
      ..lineTo(70, cy)
      ..lineTo(82, cy - 22)
      ..lineTo(96, cy + 26)
      ..lineTo(112, cy - 50)
      ..lineTo(124, cy)
      ..lineTo(center.dx, cy);
    final metric = ecg.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * line),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.primary,
    );

    if (lens <= 0) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(lens);

    final navy = Paint()..color = AppColors.logoNavy;
    canvas.drawLine(
      const Offset(25, 25),
      const Offset(46, 46),
      Paint()
        ..color = AppColors.logoNavy
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset.zero, 34, navy);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-13, -7, 26, 18),
        const Radius.circular(3),
      ),
      stroke..color = AppColors.white,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-6, -7)
        ..lineTo(-6, -12)
        ..lineTo(6, -12)
        ..lineTo(6, -7),
      stroke,
    );
    stroke.color = AppColors.secondary;
    canvas.drawLine(const Offset(0, -2), const Offset(0, 6), stroke);
    canvas.drawLine(const Offset(-4, 2), const Offset(4, 2), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeartbeatLensPainter old) =>
      old.line != line || old.lens != lens || old.pulse != pulse;
}

class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.6,
              height: 1,
              color: AppColors.logoNavy,
            ),
            children: [
              TextSpan(text: 'Cure'),
              TextSpan(
                text: 'Jobs',
                style: TextStyle(color: AppColors.logoViolet),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Find verified healthcare jobs\nnear you, in minutes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
