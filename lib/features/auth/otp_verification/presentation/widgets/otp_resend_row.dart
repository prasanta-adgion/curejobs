import 'package:flutter/material.dart';

/// "Didn't get it?" line: a countdown while resend is locked, then a
/// Resend code button.
class OtpResendRow extends StatelessWidget {
  const OtpResendRow({
    super.key,
    required this.secondsLeft,
    required this.isResending,
    required this.onResend,
  });

  final int secondsLeft;
  final bool isResending;
  final VoidCallback? onResend;

  static String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text("Didn't get it? ", style: muted),
        if (secondsLeft > 0)
          Text.rich(
            TextSpan(
              text: 'Resend in ',
              children: [
                TextSpan(
                  text: _format(secondsLeft),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            style: muted,
          )
        else
          TextButton.icon(
            onPressed: isResending ? null : onResend,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 36),
            ),
            icon: isResending
                ? const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(isResending ? 'Sending…' : 'Resend code'),
          ),
      ],
    );
  }
}
