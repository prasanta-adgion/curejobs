import 'package:flutter/material.dart';

/// Label above a field, with an optional red * and a hint line.
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

/// Looks like a text field; runs [onTap] (a picker) when tapped.
class ExperiencePickerField extends StatelessWidget {
  const ExperiencePickerField({
    super.key,
    required this.value,
    required this.placeholder,
    this.icon = Icons.keyboard_arrow_down_rounded,
    this.errorText,
    this.onTap,
  });

  final String? value;
  final String placeholder;
  final IconData icon;
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
    );
  }
}

/// "I currently work here" with a short explanation and a switch.
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

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
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
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Two fields side by side.
class ExperienceFieldPair extends StatelessWidget {
  const ExperienceFieldPair({
    super.key,
    required this.first,
    required this.second,
  });

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }
}

/// "Delete this position" link at the end of the edit form.
class DeleteExperienceButton extends StatelessWidget {
  const DeleteExperienceButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: error,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        icon: const Icon(Icons.delete_outline_rounded, size: 20),
        label: const Text('Delete this position'),
      ),
    );
  }
}
