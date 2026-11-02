import 'package:flutter/material.dart';

/// Greeting, notifications bell and profile avatar.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.name,
    required this.initials,
    this.hasUnreadNotifications = false,
    this.onNotificationsTap,
    this.onAvatarTap,
  });

  final String name;
  final String initials;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
        _CircleButton(
          onTap: onNotificationsTap,
          tooltip: 'Notifications',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_rounded, color: scheme.onSurface),
              if (hasUnreadNotifications)
                Positioned(
                  top: 0,
                  right: 1,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: scheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onAvatarTap,
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              initials,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.child, this.onTap, this.tooltip});

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 44, height: 44, child: Center(child: child)),
        ),
      ),
    );
  }
}
