import 'package:flutter/material.dart';

/// White bar pinned under the page holding the step's one action.
class VerificationBottomBar extends StatelessWidget {
  const VerificationBottomBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.helper,
    this.outlined = false,
    this.loading = false,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? helper;
  final bool outlined;

  /// Shows a small spinner before [label]; pair with a null [onPressed].
  final bool loading;

  /// Optional icon after [label], hidden while [loading].
  final IconData? trailingIcon;

  Widget _label() {
    if (!loading && trailingIcon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (loading) ...[
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
        ],
        Text(label),
        if (!loading && trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: outlined
                    ? OutlinedButton(onPressed: onPressed, child: _label())
                    : FilledButton(onPressed: onPressed, child: _label()),
              ),
              if (helper != null) ...[
                const SizedBox(height: 6),
                Text(
                  helper!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
