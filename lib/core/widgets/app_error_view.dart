import 'package:flutter/material.dart';

import '../error/failure.dart';

/// Full-area error state for a [Failure]. Shows a retry button only
/// when retrying can actually help.
class AppErrorView extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const AppErrorView({super.key, required this.failure, this.onRetry});

  IconData get _icon => switch (failure) {
    NetworkFailure() || TimeoutFailure() => Icons.wifi_off_rounded,
    UnauthorizedFailure() || ForbiddenFailure() => Icons.lock_outline_rounded,
    NotFoundFailure() => Icons.search_off_rounded,
    _ => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final retry = onRetry;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (retry != null && failure.isRetryable) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: retry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
