import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

enum _EntryAction { edit, delete }

/// ⋮ button for a profile entry (experience, education). Opens a menu below
/// itself with the entry's name on top, then "Edit details" and "Delete".
/// The button gets a purple ring while the menu is open.
class EntryMoreMenu extends StatefulWidget {
  const EntryMoreMenu({
    super.key,
    required this.title,
    required this.subtitle,
    required this.editHint,
    this.onEdit,
    this.onDelete,
  });

  /// Shown in the menu header, e.g. the degree or job title.
  final String title;

  /// Second header line, e.g. the institution or organization.
  final String subtitle;

  /// What "Edit details" covers, e.g. "Degree, years, description".
  final String editHint;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<EntryMoreMenu> createState() => _EntryMoreMenuState();
}

class _EntryMoreMenuState extends State<EntryMoreMenu> {
  final _open = ValueNotifier(false);

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<_EntryAction>(
      tooltip: 'More options',
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      menuPadding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 236, maxWidth: 260),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      popUpAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 180),
        reverseDuration: Duration(milliseconds: 120),
      ),
      onOpened: () => _open.value = true,
      onCanceled: () => _open.value = false,
      onSelected: (action) {
        _open.value = false;
        switch (action) {
          case _EntryAction.edit:
            widget.onEdit?.call();
          case _EntryAction.delete:
            widget.onDelete?.call();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<_EntryAction>(
          enabled: false,
          height: 0,
          padding: EdgeInsets.zero,
          child: _MenuHeader(title: widget.title, subtitle: widget.subtitle),
        ),
        PopupMenuItem<_EntryAction>(
          value: _EntryAction.edit,
          enabled: widget.onEdit != null,
          height: 0,
          padding: EdgeInsets.zero,
          child: _MenuRow(
            icon: Icons.edit_outlined,
            label: 'Edit details',
            subtitle: widget.editHint,
            color: scheme.primary,
            showChevron: true,
          ),
        ),
        const PopupMenuDivider(height: 9, indent: 10, endIndent: 10),
        PopupMenuItem<_EntryAction>(
          value: _EntryAction.delete,
          enabled: widget.onDelete != null,
          height: 0,
          padding: EdgeInsets.zero,
          child: _MenuRow(
            icon: AppIcons.delete,
            label: 'Delete',
            subtitle: 'Remove from your profile',
            color: scheme.error,
            labelColor: scheme.error,
          ),
        ),
      ],
      child: ValueListenableBuilder<bool>(
        valueListenable: _open,
        builder: (context, open, _) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: open ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: open
                  ? scheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: open ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Entry name at the top of the menu, so the user sees what they're
/// changing.
class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.labelColor,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color? labelColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: labelColor ?? scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (showChevron)
            Icon(Icons.chevron_right_rounded, size: 20, color: scheme.outline),
        ],
      ),
    );
  }
}
