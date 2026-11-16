import 'package:flutter/material.dart';

/// Loading state for the resume viewer. [progress] (0–1) shows a determinate
/// bar while the PDF downloads; null shows an indeterminate one.
class ResumeViewerLoading extends StatelessWidget {
  const ResumeViewerLoading({super.key, this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 3),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Loading your CV…',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
