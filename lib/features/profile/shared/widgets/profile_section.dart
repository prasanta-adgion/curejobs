import 'package:flutter/material.dart';

/// A titled block inside a profile tab. Sections are separated by a thick
/// grey band instead of cards, which keeps the page calm and easy to scan.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.showDivider = true,
  });

  final String title;
  final Widget child;

  /// Optional control on the right of the title, such as Add or Edit.
  final Widget? action;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                top: BorderSide(
                  color: scheme.surfaceContainerHighest,
                  width: 8,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 32,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (action != null) action!,
                ],
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

/// Small text button used as a section action ("Add", "Edit").
class SectionAction extends StatelessWidget {
  const SectionAction({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

/// Rounded-square icon tile used at the start of list rows.
class ProfileIconTile extends StatelessWidget {
  const ProfileIconTile({
    super.key,
    required this.icon,
    this.color,
    this.background,
    this.size = 40,
  });

  final IconData icon;
  final Color? color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: size / 2,
        color: color ?? scheme.onPrimaryContainer,
      ),
    );
  }
}
