import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

/// Red "Required" or grey "Optional" pill.
class DocumentRequiredTag extends StatelessWidget {
  const DocumentRequiredTag({super.key, required this.required});

  final bool required;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: required
            ? context.colors.errorContainer
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        required ? 'Required' : 'Optional',
        style: context.textStyles.labelSmall?.copyWith(
          color: required
              ? context.colors.onErrorContainer
              : context.colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
