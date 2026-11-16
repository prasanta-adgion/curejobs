import 'package:flutter/material.dart';

import '../../domain/entities/resume.dart';

/// Asks before deleting [resume]. Returns true when the user confirms.
Future<bool> showDeleteCvDialog(BuildContext context, Resume resume) async {
  final title = resume.title.isEmpty ? 'this CV' : '"${resume.title}"';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: const Text('Delete CV?'),
        content: Text(
          resume.isDefault
              ? '$title is your default CV for applying. Deleting it can\'t '
                    'be undone, and you\'ll need to choose another default.'
              : 'Delete $title? This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
