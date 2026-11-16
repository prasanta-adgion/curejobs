import 'package:flutter/material.dart';

/// Two side-by-side cards for adding a CV: build one from the profile, or
/// upload an existing file. Create is the primary choice.
class AddCvOptions extends StatelessWidget {
  const AddCvOptions({
    super.key,
    required this.onCreate,
    required this.onUpload,
  });

  final VoidCallback onCreate;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _OptionCard(
              icon: Icons.auto_fix_high_outlined,
              title: 'Create CV',
              subtitle: 'Filled from your profile',
              iconColor: scheme.onPrimary,
              iconBackground: scheme.primary,
              onTap: onCreate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OptionCard(
              icon: Icons.cloud_upload_outlined,
              title: 'Upload CV',
              subtitle: 'PDF or DOCX, up to 5 MB',
              iconColor: scheme.primary,
              iconBackground: scheme.primaryContainer,
              onTap: onUpload,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(14);

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 21, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
