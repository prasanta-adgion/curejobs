import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Navy header for the setup steps: back or "Account created", skip, a step
/// ring, title and subtitle. Colours are fixed, as on the other navy headers.
class CreateAccountHeader extends StatelessWidget {
  const CreateAccountHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.onSkip,
  });

  /// 1-based step number.
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;

  /// Null on the first step, which shows "Account created" instead.
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: AppColors.logoNavy,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 42,
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      tooltip: 'Back',
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.square(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: AppColors.darkInputBorder,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    )
                  else
                    const CreateAccountStatus(label: 'Account created'),
                  const Spacer(),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkPrimary,
                    ),
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _StepRing(step: step, totalSteps: totalSteps),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Green tick and short message shown on the navy header.
class CreateAccountStatus extends StatelessWidget {
  const CreateAccountStatus({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 18,
          color: AppColors.successDark,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.successDark),
        ),
      ],
    );
  }
}

class _StepRing extends StatelessWidget {
  const _StepRing({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 52,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: step / totalSteps,
            strokeWidth: 5,
            strokeCap: StrokeCap.round,
            color: AppColors.darkPrimary,
            backgroundColor: AppColors.darkInputBorder,
          ),
          Center(
            child: Text(
              '$step/$totalSteps',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
