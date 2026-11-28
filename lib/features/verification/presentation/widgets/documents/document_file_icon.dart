import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';
import 'package:curejobs/features/media_preview/presentation/models/media_file_type.dart';

/// Small tinted square with a PDF / image / generic file icon. The file
/// name is only known for files uploaded in this session, so it falls back
/// to a generic icon.
class DocumentFileIcon extends StatelessWidget {
  const DocumentFileIcon({
    super.key,
    required this.fileName,
    required this.rejected,
  });

  final String? fileName;
  final bool rejected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = fileName;
    final icon = name == null
        ? Icons.description_outlined
        : MediaFileType.fromName(name).icon;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: rejected
            ? colors.errorContainer.withValues(alpha: 0.6)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 18,
        color: rejected ? colors.error : colors.onSurfaceVariant,
      ),
    );
  }
}
