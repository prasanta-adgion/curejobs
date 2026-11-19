import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/navy_page_header.dart';
import '../../../applied_application_indetailed/presentation/pages/application_detail_page.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notifications_bloc.dart';
import '../cubit/unread_notification_count_cubit.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const NotificationsPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<NotificationsBloc>()..add(const NotificationsRequested()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  static const _loadMoreThreshold = 400.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (_scrollController.position.extentAfter > _loadMoreThreshold) return;
    final state = context.read<NotificationsBloc>().state;
    if (state.hasMore && !state.isLoadingMore && state.failure == null) {
      context.read<NotificationsBloc>().add(
        const NotificationsNextPageRequested(),
      );
    }
  }

  Future<void> _refresh() async {
    final bloc = context.read<NotificationsBloc>()
      ..add(const NotificationsRefreshed());
    sl<UnreadNotificationCountCubit>().load();
    // await bloc.stream.firstWhere((s) => !s.isLoading);
    try {
      await bloc.stream.firstWhere((state) => !state.isLoading);
    } on StateError {
      // BLoC closed before a matching state was emitted.
      print('NotificationsBloc closed before refresh completed');
    }
  }

  void _open(AppNotification n) {
    if (n.isUnread) {
      context.read<NotificationsBloc>().add(NotificationMarkedRead(n.id));
      sl<UnreadNotificationCountCubit>().markOneRead();
    }
    final applicationId = n.applicationId;
    if (applicationId != null) {
      Navigator.of(context).push(ApplicationDetailPage.route(applicationId));
    }
  }

  void _markAllRead() {
    context.read<NotificationsBloc>().add(const NotificationsAllMarkedRead());
    sl<UnreadNotificationCountCubit>().markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (p, c) =>
          c.markReadFailure != null && p.markReadFailure != c.markReadFailure,
      listener: (context, state) {
        // The badge was lowered optimistically; get the real count back.
        sl<UnreadNotificationCountCubit>().load();
        AppSnackbar.error(
          title: "Couldn't mark as read",
          message: state.markReadFailure!.failure.message,
        );
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            _Header(onMarkAllRead: _markAllRead),
            Expanded(
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state.isLoading || state.isFiltering) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == NotificationsStatus.failure) {
                    return _Message(
                      icon: Icons.cloud_off_rounded,
                      title: "Couldn't load notifications",
                      body: state.failure?.message ?? 'Check your connection.',
                      action: 'Try again',
                      onAction: () => context.read<NotificationsBloc>().add(
                        const NotificationsRequested(),
                      ),
                    );
                  }
                  if (state.items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _Message(
                            icon: Icons.notifications_active_outlined,
                            title: "You're all caught up",
                            body:
                                'New application updates and payment '
                                'receipts will show up here.',
                            action: state.filter == NotificationFilter.all
                                ? null
                                : 'View all notifications',
                            onAction: () =>
                                context.read<NotificationsBloc>().add(
                                  const NotificationsFilterChanged(
                                    NotificationFilter.all,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: _GroupedList(
                      controller: _scrollController,
                      state: state,
                      onTap: _open,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navy header with back, title, unread summary, "Mark all read" and the
/// filter chips.
class _Header extends StatelessWidget {
  const _Header({required this.onMarkAllRead});

  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      buildWhen: (p, c) => p.summary != c.summary || p.filter != c.filter,
      builder: (context, state) {
        final s = state.summary;
        return NavyPageHeader(
          title: 'Notifications',
          subtitle: s.total == 0
              ? null
              : s.unread == 0
              ? 'All caught up'
              : '${s.unread} unread of ${s.total}',
          trailing: s.unread > 0
              ? OutlinedButton.icon(
                  onPressed: onMarkAllRead,
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('Mark all read'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.white.withValues(alpha: 0.3),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              : null,
          bottom: HeaderFilterChips<NotificationFilter>(
            selected: state.filter,
            onSelected: (f) => context.read<NotificationsBloc>().add(
              NotificationsFilterChanged(f),
            ),
            items: [
              for (final f in NotificationFilter.values)
                HeaderFilterItem(
                  value: f,
                  label: f.label,
                  count: f.countIn(s),
                  highlightCount: f == NotificationFilter.unread,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// List with date section headers and a footer loader.
class _GroupedList extends StatelessWidget {
  const _GroupedList({
    required this.controller,
    required this.state,
    required this.onTap,
  });

  final ScrollController controller;
  final NotificationsState state;
  final ValueChanged<AppNotification> onTap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    String? lastGroup;
    for (final n in state.items) {
      final group = notificationGroupLabel(n.createdAt);
      if (group != lastGroup) {
        rows.add(_GroupHeader(group));
        lastGroup = group;
      }
      rows.add(NotificationTile(notification: n, onTap: () => onTap(n)));
    }

    return ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: rows.length + 1,
      itemBuilder: (context, i) {
        if (i < rows.length) return rows[i];
        if (state.isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (state.hasMore && state.failure != null) {
          return Center(
            child: TextButton(
              onPressed: () => context.read<NotificationsBloc>().add(
                const NotificationsNextPageRequested(),
              ),
              child: const Text('Load more'),
            ),
          );
        }
        return const SizedBox(height: 24);
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Empty and error states.
class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 72, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: scheme.primary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}
