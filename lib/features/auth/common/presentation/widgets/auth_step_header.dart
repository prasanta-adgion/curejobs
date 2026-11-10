import 'package:flutter/material.dart';

/// Compact purple top bar for multi-step auth flows: back button,
/// "Step x of y" and a segmented progress bar. A card is expected to
/// overlap its bottom edge by roughly [bottomPadding] - 16.
class AuthStepHeader extends StatelessWidget {
  const AuthStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.bottomPadding = 64,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final double bottomPadding;

  /// Defaults to popping the route when null.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;
    final canGoBack = onBack != null || Navigator.canPop(context);

    return Container(
      width: double.infinity,
      color: scheme.primary,
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  if (canGoBack) ...[
                    IconButton(
                      onPressed: onBack ?? () => Navigator.maybePop(context),
                      tooltip: 'Back',
                      style: IconButton.styleFrom(
                        backgroundColor: onPrimary.withValues(alpha: 0.18),
                        foregroundColor: onPrimary,
                      ),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'Step $currentStep of $totalSteps',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Step $currentStep of $totalSteps',
              excludeSemantics: true,
              child: Row(
                children: [
                  for (var i = 0; i < totalSteps; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i < currentStep
                              ? onPrimary
                              : onPrimary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
