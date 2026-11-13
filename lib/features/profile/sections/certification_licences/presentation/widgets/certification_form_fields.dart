import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';
import '../../domain/entities/certification.dart';
import '../models/certification_ui.dart';

/// Label above a field, with an optional red * and a hint line.
class CertificationLabeledField extends StatelessWidget {
  const CertificationLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.enabled = true,
    this.hint,
  });

  final String label;
  final Widget child;
  final bool required;
  final bool enabled;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (required && enabled)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: scheme.error),
                ),
            ],
          ),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled ? null : scheme.outline,
          ),
        ),
        const SizedBox(height: 6),
        if (hint != null) ...[
          Text(
            hint!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        child,
      ],
    );
  }
}

/// Looks like a text field; opens the date picker when tapped.
class CertificationDateField extends StatelessWidget {
  const CertificationDateField({
    super.key,
    required this.value,
    this.errorText,
    this.onTap,
  });

  final String? value;
  final String? errorText;

  /// Null disables the field.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          hintText: 'Month, year',
          enabled: enabled,
          errorText: errorText,
          suffixIcon: Icon(
            AppIcons.calendar,
            size: 18,
            color: enabled ? scheme.onSurfaceVariant : scheme.outline,
          ),
        ),
        child: value == null
            ? null
            : Text(
                value!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: enabled ? null : scheme.outline,
                ),
              ),
      ),
    );
  }
}

/// Small tappable chip, purple with a check when [selected].
class CertificationChip extends StatelessWidget {
  const CertificationChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.6)
          : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.fromLTRB(selected ? 6 : 10, 6, 10, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 14, color: scheme.primary),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onTap == null
                      ? scheme.outline
                      : selected
                      ? scheme.primary
                      : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Common certificates as chips under the Name field. One tap fills it.
class CertificationNameSuggestions extends StatelessWidget {
  const CertificationNameSuggestions({
    super.key,
    required this.controller,
    required this.onPicked,
  });

  static const names = [
    'Nursing council licence',
    'BLS Provider',
    'ACLS',
    'PALS',
    'NRP',
    'Infection control',
    'IV therapy',
  ];

  final TextEditingController controller;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final typed = value.text.trim().toLowerCase();
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final name in names)
              CertificationChip(
                label: name,
                selected: typed == name.toLowerCase(),
                onTap: () => onPicked(name),
              ),
          ],
        );
      },
    );
  }
}

/// "Doesn't expire" with a short explanation and a switch.
class NoExpiryTile extends StatelessWidget {
  const NoExpiryTile({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: value
          ? scheme.primaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value
              ? scheme.primary.withValues(alpha: 0.45)
              : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
          child: Row(
            children: [
              Icon(
                Icons.all_inclusive_rounded,
                size: 20,
                color: scheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Doesn't expire",
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Like a lifetime registration',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// How the certificate will look on the profile, updated as the user types.
class CertificationPreviewCard extends StatelessWidget {
  const CertificationPreviewCard({super.key, required this.certification});

  final Certification certification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = certification;
    final style = certificationStatusStyle(c.status, scheme);
    final name = c.name.trim().isEmpty ? 'Certificate name' : c.name.trim();
    final details = [
      if (c.issuingOrganization.trim().isNotEmpty) c.issuingOrganization.trim(),
      if (c.issueDate != null || c.expiryDate != null) c.validityLabel,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.workspace_premium_outlined,
                  size: 20,
                  color: style.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.name.trim().isEmpty ? scheme.outline : null,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  style.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: style.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Live preview, as hospitals will see it',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}

/// Red "Delete this certificate" row in the Manage section.
class DeleteCertificationButton extends StatelessWidget {
  const DeleteCertificationButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: error.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(AppIcons.delete, size: 20, color: error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delete this certificate',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: error),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main button pinned to the bottom, above the keyboard.
class CertificationSaveBar extends StatelessWidget {
  const CertificationSaveBar({
    super.key,
    required this.label,
    required this.isSaving,
    this.onSave,
  });

  final String label;
  final bool isSaving;
  final VoidCallback? onSave;

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
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Saving…'),
                      ],
                    )
                  : Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

/// Amber "Unsaved" tag shown in the app bar while there are edits.
class CertificationUnsavedTag extends StatelessWidget {
  const CertificationUnsavedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Unsaved',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFFB45309),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
