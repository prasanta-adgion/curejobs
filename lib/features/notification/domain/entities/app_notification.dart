import 'package:equatable/equatable.dart';

/// API `category`. [system] is shown to the user as "Account".
enum NotificationCategory {
  applications('APPLICATIONS', 'Applications'),
  jobs('JOBS', 'Jobs'),
  system('SYSTEM', 'Account'),
  other('', 'Other');

  const NotificationCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static NotificationCategory fromApi(String value) => values.firstWhere(
    (c) => c.apiValue.isNotEmpty && c.apiValue == value.toUpperCase(),
    orElse: () => other,
  );
}

/// API `type`.
enum NotificationType {
  paymentSucceeded,
  applicationSubmitted,
  applicationStatusChanged,
  verificationApproved,
  unknown;

  static NotificationType fromApi(String value) => switch (value) {
    'PAYMENT_SUCCEEDED' => paymentSucceeded,
    'APPLICATION_SUBMITTED' => applicationSubmitted,
    'APPLICATION_STATUS_CHANGED' => applicationStatusChanged,
    'CANDIDATE_VERIFICATION_APPROVED' => verificationApproved,
    _ => unknown,
  };
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.category,
    required this.subject,
    required this.createdAt,
    this.readAt,
    this.payload = const {},
  });

  final String id;
  final NotificationType type;
  final NotificationCategory category;
  final String subject;
  final DateTime createdAt;
  final DateTime? readAt;

  /// Raw `payloadJson`; keys differ per [type].
  final Map<String, dynamic> payload;

  bool get isUnread => readAt == null;

  String? _str(String key) {
    final v = payload[key];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  String? get jobTitle => _str('jobTitle');
  String? get organizationName => _str('organizationName');
  String? get applicationId => _str('applicationId');
  String? get targetUrl => _str('targetUrl');

  /// Payload `status` for application updates (e.g. `UNDER_REVIEW`).
  String? get applicationStatus =>
      type == NotificationType.applicationStatusChanged ? _str('status') : null;

  String get title => switch (type) {
    NotificationType.applicationSubmitted => 'Application submitted',
    NotificationType.applicationStatusChanged => jobTitle ?? subject,
    _ => subject,
  };

  String? get body {
    String? join(List<String?> parts) {
      final p = parts.whereType<String>().toList();
      return p.isEmpty ? null : p.join(' · ');
    }

    final amount = _str('amountLabel');
    return switch (type) {
      NotificationType.paymentSucceeded => join([
        amount == null ? null : '$amount paid',
        _str('accessLabel'),
      ]),
      NotificationType.applicationSubmitted => join([
        jobTitle,
        organizationName,
      ]),
      NotificationType.applicationStatusChanged =>
        organizationName != null
            ? '$organizationName moved your application'
            : 'Your application status changed',
      NotificationType.verificationApproved =>
        'Your profile now shows a verified badge',
      NotificationType.unknown => null,
    };
  }

  AppNotification markRead([DateTime? at]) => AppNotification(
    id: id,
    type: type,
    category: category,
    subject: subject,
    createdAt: createdAt,
    readAt: readAt ?? at ?? DateTime.now(),
    payload: payload,
  );

  @override
  List<Object?> get props => [id, readAt];
}

class NotificationSummary extends Equatable {
  const NotificationSummary({
    this.total = 0,
    this.unread = 0,
    this.applications = 0,
    this.jobs = 0,
    this.system = 0,
  });

  final int total;
  final int unread;
  final int applications;
  final int jobs;
  final int system;

  int countOf(NotificationCategory c) => switch (c) {
    NotificationCategory.applications => applications,
    NotificationCategory.jobs => jobs,
    NotificationCategory.system => system,
    NotificationCategory.other => 0,
  };

  NotificationSummary copyWith({int? unread}) => NotificationSummary(
    total: total,
    unread: unread ?? this.unread,
    applications: applications,
    jobs: jobs,
    system: system,
  );

  @override
  List<Object?> get props => [total, unread, applications, jobs, system];
}

class NotificationsPage {
  const NotificationsPage({
    required this.items,
    required this.summary,
    required this.page,
    required this.hasMore,
  });

  final List<AppNotification> items;
  final NotificationSummary summary;
  final int page;
  final bool hasMore;
}
