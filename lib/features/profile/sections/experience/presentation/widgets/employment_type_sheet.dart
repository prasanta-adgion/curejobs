import 'package:flutter/material.dart';

import '../../domain/entities/employment_type.dart';

/// Bottom sheet listing employment types. Returns the one tapped.
Future<EmploymentType?> showEmploymentTypeSheet(
  BuildContext context, {
  EmploymentType? selected,
}) {
  return showModalBottomSheet<EmploymentType>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Employment type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final type in EmploymentType.values)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Text(type.label),
                trailing: type == selected
                    ? Icon(Icons.check_rounded, color: scheme.primary)
                    : null,
                selected: type == selected,
                onTap: () => Navigator.of(context).pop(type),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
