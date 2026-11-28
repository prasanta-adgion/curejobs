import 'package:flutter/material.dart';

import 'package:curejobs/core/services/picked_file.dart';
import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import 'added_document.dart';

/// The picked (already uploaded) file in the upload form, with Replace and
/// Clear buttons. Both are disabled (null) while the form is attaching it.
class ChosenFileTile extends StatelessWidget {
  const ChosenFileTile({
    super.key,
    required this.file,
    required this.onReplace,
    required this.onClear,
  });

  final PickedFile file;
  final VoidCallback? onReplace;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final isPdf = file.name.toLowerCase().endsWith('.pdf');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            color: context.colors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  formatFileSize(file.sizeInBytes),
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Replace',
            onPressed: onReplace,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
