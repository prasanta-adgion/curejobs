import 'package:flutter/material.dart';

import '../../../../features/profile/shared/widgets/profile_section.dart';

/// Where a verification document should come from.
enum DocumentSource { camera, gallery, files }

/// Bottom sheet titled with the document's name. Returns null if dismissed.
Future<DocumentSource?> showDocumentSourceSheet(
  BuildContext context, {
  required String documentName,
}) {
  return showModalBottomSheet<DocumentSource>(
    context: context,
    showDragHandle: true,
    builder: (_) => _DocumentSourceSheet(documentName: documentName),
  );
}

class _DocumentSourceSheet extends StatelessWidget {
  const _DocumentSourceSheet({required this.documentName});

  final String documentName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget option(
      DocumentSource source,
      IconData icon,
      String title,
      String subtitle,
    ) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        leading: ProfileIconTile(icon: icon),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        onTap: () => Navigator.of(context).pop(source),
      );
    }

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose how to add it',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          option(
            DocumentSource.camera,
            Icons.photo_camera_outlined,
            'Take photo',
            'Use your camera',
          ),
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: scheme.outlineVariant,
          ),
          option(
            DocumentSource.gallery,
            Icons.photo_library_outlined,
            'Choose from gallery',
            'JPG or PNG',
          ),
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: scheme.outlineVariant,
          ),
          option(
            DocumentSource.files,
            Icons.description_outlined,
            'Browse files',
            'PDF up to 5 MB',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
