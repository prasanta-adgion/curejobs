import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_icons.dart';

enum _CvAction { setDefault, download, rename, delete }

/// ⋮ menu on a CV card: set as default, download, rename and delete.
/// A null callback disables that row.
class CvMoreMenu extends StatelessWidget {
  const CvMoreMenu({
    super.key,
    this.onSetDefault,
    this.onDownload,
    this.onRename,
    this.onDelete,
  });

  final VoidCallback? onSetDefault;
  final VoidCallback? onDownload;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    PopupMenuItem<_CvAction> item(
      _CvAction value,
      IconData icon,
      String label,
      VoidCallback? onTap, {
      Color? color,
    }) {
      final c = color ?? scheme.onSurface;
      return PopupMenuItem<_CvAction>(
        value: value,
        enabled: onTap != null,
        height: 44,
        child: Row(
          children: [
            Icon(icon, size: 19, color: onTap == null ? scheme.outline : c),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: onTap == null ? null : c)),
          ],
        ),
      );
    }

    return PopupMenuButton<_CvAction>(
      tooltip: 'More options',
      position: PopupMenuPosition.under,
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      constraints: const BoxConstraints(minWidth: 200),
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
      padding: EdgeInsets.zero,
      onSelected: (action) => switch (action) {
        _CvAction.setDefault => onSetDefault?.call(),
        _CvAction.download => onDownload?.call(),
        _CvAction.rename => onRename?.call(),
        _CvAction.delete => onDelete?.call(),
      },
      itemBuilder: (_) => [
        item(
          _CvAction.setDefault,
          Icons.star_outline_rounded,
          'Set as default',
          onSetDefault,
        ),
        item(
          _CvAction.download,
          Icons.download_outlined,
          'Download',
          onDownload,
        ),
        item(_CvAction.rename, Icons.edit_outlined, 'Rename', onRename),
        const PopupMenuDivider(height: 8),
        item(
          _CvAction.delete,
          AppIcons.delete,
          'Delete',
          onDelete,
          color: scheme.error,
        ),
      ],
    );
  }
}
