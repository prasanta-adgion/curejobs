import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';

/// Label above a field, with an optional red * and a hint line.
class EducationLabeledField extends StatelessWidget {
  const EducationLabeledField({
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

  /// Shown between the label and the field.
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

/// Looks like a text field; runs [onTap] (the year picker) when tapped.
class EducationPickerField extends StatelessWidget {
  const EducationPickerField({
    super.key,
    required this.value,
    required this.placeholder,
    this.errorText,
    this.onTap,
  });

  final String? value;
  final String placeholder;
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
          hintText: placeholder,
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

/// "I study here now" with a short explanation and a switch.
class StudyingNowTile extends StatelessWidget {
  const StudyingNowTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

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
              Icon(Icons.school_outlined, size: 20, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I study here now',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Shows as Ongoing on your profile',
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

/// Common degrees as chips under the Degree field. One tap fills it.
class DegreeSuggestions extends StatelessWidget {
  const DegreeSuggestions({
    super.key,
    required this.controller,
    required this.onPicked,
  });

  static const degrees = [
    'B.Sc. Nursing',
    'GNM',
    'ANM',
    'Post Basic B.Sc. Nursing',
    'M.Sc. Nursing',
    'MBBS',
    'BDS',
    'B.Pharm',
    'BPT',
    'DMLT',
  ];

  final TextEditingController controller;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Only the chips redraw as the user types.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final typed = value.text.trim().toLowerCase();
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final degree in degrees)
              _Chip(
                label: degree,
                selected: typed == degree.toLowerCase(),
                onTap: () => onPicked(degree),
                theme: theme,
                scheme: scheme,
              ),
          ],
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
    required this.scheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
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
                  color: selected ? scheme.primary : scheme.onSurface,
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

/// Red "Delete this education" row in the Manage section.
class DeleteEducationButton extends StatelessWidget {
  const DeleteEducationButton({super.key, this.onPressed});

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
              Icon(Icons.delete_outline_rounded, size: 20, color: error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delete this education',
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
class EducationSaveBar extends StatelessWidget {
  const EducationSaveBar({
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
class EducationUnsavedTag extends StatelessWidget {
  const EducationUnsavedTag({super.key});

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
