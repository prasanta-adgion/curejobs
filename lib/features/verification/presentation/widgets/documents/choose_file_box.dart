import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

/// Dashed-style "Choose file" drop zone of the upload form. Disabled until
/// a document type is picked, so every file gets a type.
class ChooseFileBox extends StatelessWidget {
  const ChooseFileBox({super.key, required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    final color = enabled ? context.colors.primary : context.colors.outline;

    return Material(
      color: enabled
          ? context.colors.primaryContainer.withValues(alpha: 0.5)
          : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, color: color),
              const SizedBox(height: 4),
              Text(
                'Choose file',
                style: context.textStyles.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                enabled
                    ? 'Camera, gallery or files · PDF, JPG, PNG up to 5 MB'
                    : 'Select a document type first',
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
