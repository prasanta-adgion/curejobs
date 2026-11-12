import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

/// Label above a field. Required fields get a red *, optional ones a small
/// "Optional" tag, so users know what they can skip.
class ExperienceLabeledField extends StatelessWidget {
  const ExperienceLabeledField({
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
        Row(
          children: [
            Flexible(
              child: Text.rich(
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
            ),
            if (!required && enabled) ...[
              const SizedBox(width: 6),
              Text(
                'Optional',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ],
          ],
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

/// Looks like a text field; runs [onTap] (a picker) when tapped.
/// Pass [onClear] to show an × that empties an optional value.
class ExperiencePickerField extends StatelessWidget {
  const ExperiencePickerField({
    super.key,
    required this.value,
    required this.placeholder,
    this.icon = Icons.keyboard_arrow_down_rounded,
    this.errorText,
    this.onTap,
    this.onClear,
  });

  final String? value;
  final String placeholder;
  final IconData icon;
  final String? errorText;

  /// Null disables the field.
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    final canClear = enabled && onClear != null && value != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: value == null ? placeholder : '$placeholder: $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          isEmpty: value == null,
          decoration: InputDecoration(
            hintText: placeholder,
            enabled: enabled,
            errorText: errorText,
            suffixIcon: canClear
                ? IconButton(
                    tooltip: 'Clear',
                    onPressed: onClear,
                    icon: Icon(
                      AppIcons.close,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    icon,
                    size: icon == Icons.keyboard_arrow_down_rounded ? 24 : 18,
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
      ),
    );
  }
}

/// "I currently work here" as a tappable card. Turns purple when on, so
/// it's obvious why End date shows Present.
class CurrentlyWorkingTile extends StatelessWidget {
  const CurrentlyWorkingTile({
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
              Icon(
                Icons.work_history_outlined,
                size: 20,
                color: scheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I currently work here',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'End date will show as Present',
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

/// Two fields side by side, or stacked on very narrow screens so neither
/// gets cramped.
class ExperienceFieldPair extends StatelessWidget {
  const ExperienceFieldPair({
    super.key,
    required this.first,
    required this.second,
  });

  static const _stackBelow = 320.0;

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _stackBelow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 14), second],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

/// Common nursing and hospital roles as chips under Job title. One tap
/// fills the field; the matching chip shows a check.
class JobTitleSuggestions extends StatelessWidget {
  const JobTitleSuggestions({
    super.key,
    required this.controller,
    required this.onPicked,
  });

  static const titles = [
    'Staff Nurse',
    'Senior Staff Nurse',
    'ICU Nurse',
    'OT Nurse',
    'Nursing Supervisor',
    'Ward In-charge',
    'Nursing Tutor',
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
            for (final title in titles)
              Builder(
                builder: (context) {
                  final selected = typed == title.toLowerCase();
                  return Material(
                    color: selected
                        ? scheme.primaryContainer.withValues(alpha: 0.6)
                        : scheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: selected
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => onPicked(title),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          selected ? 6 : 10,
                          6,
                          10,
                          6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected) ...[
                              Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: selected
                                    ? scheme.primary
                                    : scheme.onSurface,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

/// Red "Delete this position" row in the Manage section, with a border so
/// it reads as a deliberate action, not a link.
class DeleteExperienceButton extends StatelessWidget {
  const DeleteExperienceButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    final enabled = onPressed != null;
    final color = enabled ? error : error.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delete this position',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
