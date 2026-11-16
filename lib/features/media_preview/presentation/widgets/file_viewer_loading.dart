import 'package:flutter/material.dart';

/// Loading state for the file viewer. [progress] (0–1) shows a determinate
/// bar while the file downloads; null shows an indeterminate one.
class FileViewerLoading extends StatelessWidget {
  const FileViewerLoading({super.key, this.progress});

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
                  'Loading file…',
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
