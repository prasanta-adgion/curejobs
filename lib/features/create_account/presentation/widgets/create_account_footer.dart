import 'package:flutter/material.dart';

/// Fixed bottom bar with the main action and an optional Back button.
class CreateAccountFooter extends StatelessWidget {
  const CreateAccountFooter({
    super.key,
    required this.label,
    required this.onPressed,
    this.onBack,
    this.showArrow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onBack;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              if (onBack != null) ...[
                OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(84, 52),
                  ),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: onPressed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label),
                      if (showArrow) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
