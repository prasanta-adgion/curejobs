import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';

enum SearchField { keyword, location }

/// One rounded search input. The focused one gets a primary outline so it
/// is clear which field the list below belongs to.
class SearchInputField extends StatelessWidget {
  const SearchInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.active,
    required this.icon,
    required this.hint,
    required this.action,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool active;
  final IconData icon;
  final String hint;
  final TextInputAction action;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: active ? scheme.primary : scheme.outlineVariant,
          width: active ? 1.5 : 1,
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: action,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => onSubmitted?.call(),
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            prefixIcon: Icon(icon, size: 22, color: scheme.onSurface),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: () {
                      controller.clear();
                      focusNode.requestFocus();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
