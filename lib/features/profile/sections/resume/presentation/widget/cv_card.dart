import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/resume.dart';
import 'cv_more_menu.dart';
import 'cv_thumbnail.dart';

/// One CV in the "Your CVs" list: thumbnail, title, details, a default
/// badge, View and Edit buttons, and a ⋮ menu. The default CV gets a
/// highlighted border.
class CvCard extends StatelessWidget {
  const CvCard({
    super.key,
    required this.resume,
    required this.isBusy,
    required this.onView,
    required this.onEdit,
    required this.onDownload,
    required this.onSetDefault,
    required this.onRename,
    required this.onDelete,
  });

  final Resume resume;

  /// A download or set-default request is running for this CV.
  final bool isBusy;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDownload;
  final VoidCallback onSetDefault;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  String get _title => resume.title.isEmpty ? 'My Resume' : resume.title;

  String get _subtitle {
    if (resume.isUploaded) return 'Uploaded';
    final key = resume.templateKey!.trim();
    final name = key[0].toUpperCase() + key.substring(1);
    return 'Created · $name template';
  }

  String? get _updatedLabel {
    final date = resume.updatedAt ?? resume.createdAt;
    if (date == null) return null;
    return 'Updated ${DateTimeUtils.day(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final updated = _updatedLabel;
    final ready = resume.hasFile;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: resume.isDefault
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outlineVariant,
          width: resume.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CvThumbnail(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(_subtitle, style: muted),
                    if (updated != null) Text(updated, style: muted),
                    if (resume.isDefault) ...[
                      const SizedBox(height: 8),
                      const _DefaultBadge(),
                    ] else if (!ready) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Generating PDF…',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              CvMoreMenu(
                onSetDefault: resume.isDefault || isBusy ? null : onSetDefault,
                onDownload: ready && !isBusy ? onDownload : null,
                onRename: onRename,
                onDelete: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Expanded(
                  child: _CardButton(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    onPressed: ready ? onView : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CardButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
          ),
          if (isBusy) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: const LinearProgressIndicator(minHeight: 3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 13,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Default for applying',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        minimumSize: const Size.fromHeight(40),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
