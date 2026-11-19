part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// First load, showing the full-screen loader.
final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested();
}

/// Pull to refresh; keeps the current list visible.
final class NotificationsRefreshed extends NotificationsEvent {
  const NotificationsRefreshed();
}

/// Scrolled near the end of the list.
final class NotificationsNextPageRequested extends NotificationsEvent {
  const NotificationsNextPageRequested();
}

final class NotificationsFilterChanged extends NotificationsEvent {
  const NotificationsFilterChanged(this.filter);

  final NotificationFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// One notification was opened.
final class NotificationMarkedRead extends NotificationsEvent {
  const NotificationMarkedRead(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class NotificationsAllMarkedRead extends NotificationsEvent {
  const NotificationsAllMarkedRead();
}
