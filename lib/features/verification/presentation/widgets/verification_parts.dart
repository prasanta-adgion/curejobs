import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../profile/shared/widgets/profile_section.dart';

/// Icon tile with a title and a supporting line, used at the top of a step.
class VerificationHero extends StatelessWidget {
  const VerificationHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.background,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ProfileIconTile(
          icon: icon,
          size: 48,
          color: color,
          background: background,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Green tick and a line of text, for plan benefits.
class VerificationCheckLine extends StatelessWidget {
  const VerificationCheckLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Label on the left, value on the right, with a hairline under it.
class VerificationInfoRow extends StatelessWidget {
  const VerificationInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: scheme.outlineVariant))
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small coloured pill such as "In review".
class VerificationTag extends StatelessWidget {
  const VerificationTag({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Tinted note with a leading icon, e.g. "Advanced plan active".
class VerificationNote extends StatelessWidget {
  const VerificationNote({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

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

/// Shown on the documents step before the upload form: what's about to
/// happen and what to keep handy. "Start verification" lives in the bottom
/// bar; [error] (from a failed start) shows here with a retry.
class VerificationStartCard extends StatelessWidget {
  const VerificationStartCard({super.key, this.error, this.onRetry});

  final String? error;
  final VoidCallback? onRetry;

  static const _steps = [
    (title: 'Choose a document type', subtitle: "Pick what you're uploading"),
    (
      title: 'Take a photo or pick a file',
      subtitle: 'PDF, JPG or PNG up to 5 MB',
    ),
    (title: 'Submit for review', subtitle: 'We check within 2 working days'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const VerificationHero(
          icon: Icons.verified_user_outlined,
          title: 'Ready to get verified?',
          subtitle: '3 simple steps, about 2 minutes.',
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _steps[i].title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(_steps[i].subtitle, style: muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Divider(height: 1, color: scheme.outlineVariant),
        const SizedBox(height: 12),
        Text('Keep these handy', style: muted),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HandyChip(icon: Icons.badge_outlined, label: 'Government ID'),
            _HandyChip(
              icon: Icons.workspace_premium_outlined,
              label: 'Medical licence',
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
                if (onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onErrorContainer,
                    ),
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HandyChip extends StatelessWidget {
  const _HandyChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
