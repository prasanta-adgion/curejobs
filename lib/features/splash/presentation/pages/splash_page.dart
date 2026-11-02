import 'dart:math' as math;

import 'package:curejobs/features/bottom_nav/bottom_navbar.dart';
import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../appearance_page.dart';
import '../../../auth/login/presentation/pages/login_page.dart';

/// First screen of the app. Plays the intro while checking for a saved
/// session, then opens the Appearance page or the Login page.
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.duration = const Duration(milliseconds: 3000),
  });

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

    _whereToGo();
  }

  /// Checks the session while the intro plays, then opens the next screen.
  Future<void> _whereToGo() async {
    final session = _hasSession();
    await _intro.forward().orCancel.catchError((_) {});
    final loggedIn = await session;
    if (!mounted) return;

    _replaceWith(
      loggedIn
          ? const DashboardPage()
          : LoginPage(onLoggedIn: (_) => _replaceWith(const DashboardPage())),
    );
  }

  /// A storage error is treated as signed out.
  Future<bool> _hasSession() async {
    try {
      return await sl<SessionStorageInterface>().hasSession();
    } catch (_) {
      return false;
    }
  }

  void _replaceWith(Widget page) {
    final navigator = _navigator ??= Navigator.of(context);
    navigator.pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
  }

  NavigatorState? _navigator;

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                                  primary: theme.colorScheme.primary,
                                  primaryContainer:
                                      theme.colorScheme.primaryContainer,
                                  secondary: theme.colorScheme.secondary,
                                  onPrimary: theme.colorScheme.onPrimary,
                                  onSurface: theme.colorScheme.onSurface,
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
                        backgroundColor: theme.colorScheme.primaryContainer,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
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
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.onPrimary,
    required this.onSurface,
  });

  final double line;
  final double lens;
  final double pulse;
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color onPrimary;
  final Color onSurface;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, 78, Paint()..color = primaryContainer);

    if (lens > 0) {
      canvas.drawCircle(
        center,
        46 + 32 * pulse,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = secondary.withValues(alpha: 0.5 * (1 - pulse)),
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
        ..color = primary,
    );

    if (lens <= 0) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(lens);

    final navy = Paint()..color = onSurface;
    canvas.drawLine(
      const Offset(25, 25),
      const Offset(46, 46),
      Paint()
        ..color = onSurface
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
      stroke..color = onPrimary,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-6, -7)
        ..lineTo(-6, -12)
        ..lineTo(6, -12)
        ..lineTo(6, -7),
      stroke,
    );
    stroke.color = secondary;
    canvas.drawLine(const Offset(0, -2), const Offset(0, 6), stroke);
    canvas.drawLine(const Offset(-4, 2), const Offset(4, 2), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeartbeatLensPainter old) =>
      old.line != line ||
      old.lens != lens ||
      old.pulse != pulse ||
      old.primary != primary ||
      old.primaryContainer != primaryContainer ||
      old.secondary != secondary ||
      old.onPrimary != onPrimary ||
      old.onSurface != onSurface;
}

class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Image.asset(
          AssetPaths.logo,
          width: 190,
          fit: BoxFit.contain,
          semanticLabel: 'CureJobs',
        ),
        const SizedBox(height: 12),
        Text(
          'Find verified healthcare jobs\nnear you, in minutes',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
