import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/picked_file.dart';
import '../models/media_file_type.dart';

/// Icon, name, type and size of a picked document.
class DocumentPreview extends StatelessWidget {
  const DocumentPreview({super.key, required this.file, required this.type});

  final PickedFile file;
  final MediaFileType type;

  String get _size {
    final kilobytes = file.sizeInBytes / 1024;
    if (kilobytes < 1024) return '${kilobytes.ceil()} KB';
    return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkInputBorder),
              ),
              child: Icon(type.icon, size: 44, color: AppColors.darkPrimary),
            ),
            const SizedBox(height: 18),
            Text(
              file.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${type.label} · $_size',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
