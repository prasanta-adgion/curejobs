import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';

/// One notification row: tinted icon, title, one-line detail, then time
/// and a category or status tag. Unread rows get a tinted background,
/// a bold title and a red dot.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final n = notification;
    final look = _Look.of(n);
    final tag = _tagFor(n);
    final body = n.body;

    return Material(
      color: n.isUnread
          ? scheme.primary.withValues(alpha: 0.06)
          : scheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: look.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(look.icon, size: 18, color: look.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: n.isUnread
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (body != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          formatNotificationTime(n.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Tag(label: tag.$1, color: tag.$2),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 16,
                child: n.isUnread
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, left: 8),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Status updates show the new status; others show their category.
  static (String, Color) _tagFor(AppNotification n) {
    final status = n.applicationStatus;
    if (status != null) return (_statusLabel(status), _statusColor(status));
    return switch (n.category) {
      NotificationCategory.applications => ('Applications', AppColors.info),
      NotificationCategory.jobs => ('Jobs', AppColors.primary),
      _ => (n.category.label, AppColors.lightTextSecondary),
    };
  }

  static String _statusLabel(String s) {
    final words = s.toLowerCase().split('_');
    final text = words.join(' ');
    return text.isEmpty ? s : text[0].toUpperCase() + text.substring(1);
  }

  static Color _statusColor(String s) => switch (s.toUpperCase()) {
    'SHORTLISTED' || 'HIRED' || 'SELECTED' || 'OFFERED' => AppColors.success,
    'REJECTED' || 'WITHDRAWN' => AppColors.error,
    _ => AppColors.warning,
  };
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _Look {
  const _Look(this.icon, this.color);

  final IconData icon;
  final Color color;

  static _Look of(AppNotification n) => switch (n.type) {
    NotificationType.paymentSucceeded => const _Look(
      Icons.receipt_long_rounded,
      AppColors.success,
    ),
    NotificationType.applicationSubmitted => const _Look(
      Icons.send_rounded,
      AppColors.info,
    ),
    NotificationType.applicationStatusChanged => _Look(
      Icons.timelapse_rounded,
      NotificationTile._statusColor(n.applicationStatus ?? ''),
    ),
    NotificationType.verificationApproved => const _Look(
      Icons.verified_rounded,
      Color(0xFF0F766E),
    ),
    NotificationType.unknown => const _Look(
      Icons.notifications_none_rounded,
      AppColors.lightTextSecondary,
    ),
  };
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "5:03 PM" for today and yesterday, "6 Nov" this year, else "6 Nov 2025".
String formatNotificationTime(DateTime t, {DateTime? now}) {
  final today = _day(now ?? DateTime.now());
  final diff = today.difference(_day(t)).inDays;
  if (diff <= 1) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }
  final base = '${t.day} ${_months[t.month - 1]}';
  return t.year == today.year ? base : '$base ${t.year}';
}

/// Section header: Today, Yesterday, Earlier this month, then month names.
String notificationGroupLabel(DateTime t, {DateTime? now}) {
  final today = _day(now ?? DateTime.now());
  final diff = today.difference(_day(t)).inDays;
  if (diff <= 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (t.year == today.year && t.month == today.month) {
    return 'Earlier this month';
  }
  const full = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final month = full[t.month - 1];
  return t.year == today.year ? month : '$month ${t.year}';
}

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);
