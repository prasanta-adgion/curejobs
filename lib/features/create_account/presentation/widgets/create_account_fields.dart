import 'package:flutter/material.dart';

/// Field label with an optional red star or "(optional)" note.
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.isOptional = false,
  });

  final String label;
  final bool isRequired;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(color: scheme.error),
              ),
            if (isOptional)
              TextSpan(
                text: ' (optional)',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.helper,
    this.isRequired = false,
    this.isOptional = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.words,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? helper;
  final bool isRequired;
  final bool isOptional;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(
          label: label,
          isRequired: isRequired,
          isOptional: isOptional,
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(hintText: hint, helperText: helper),
        ),
      ],
    );
  }
}

class LabeledDropdown extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> options;

  /// Null disables the field.
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label),
        DropdownButtonFormField<String>(
          // Rebuilds the field when the value is reset from outside.
          key: ValueKey('$label-$value-${options.join()}'),
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: Text(hint, overflow: TextOverflow.ellipsis),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(option, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Looks like a text field; opens a picker page when tapped.
class LabeledPickerField extends StatelessWidget {
  const LabeledPickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final String? value;

  /// Null disables the field.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            isEmpty: value == null,
            decoration: InputDecoration(
              hintText: hint,
              enabled: enabled,
              suffixIcon: const Icon(Icons.chevron_right_rounded),
            ),
            child: value == null
                ? null
                : Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
          ),
        ),
      ],
    );
  }
}

/// Two fields side by side.
class FieldPair extends StatelessWidget {
  const FieldPair({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}
