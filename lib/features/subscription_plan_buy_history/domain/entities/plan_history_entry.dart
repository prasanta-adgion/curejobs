import 'package:equatable/equatable.dart';

enum PlanHistoryStatus {
  active('ACTIVE', 'Active'),
  expired('EXPIRED', 'Expired'),
  cancelled('CANCELLED', 'Ended'),
  unknown('', 'Ended');

  const PlanHistoryStatus(this.apiValue, this.label);

  final String apiValue;

  /// Shown to the user. "Cancelled" reads as if they cancelled it, but these
  /// plans were replaced, so it shows as "Ended".
  final String label;

  static PlanHistoryStatus fromApi(String value) => values.firstWhere(
    (s) => s.apiValue == value,
    orElse: () => PlanHistoryStatus.unknown,
  );
}

/// How the user got a plan, from `source`.
enum PlanSource {
  paidPurchase('PAID_PURCHASE', 'Purchased'),
  systemFallback('SYSTEM_FALLBACK', 'Auto-assigned'),
  selfSelected('SELF_SELECTED', 'Selected by you'),
  adminGrant('ADMIN_GRANT', 'Granted by admin'),
  adminReplacement('ADMIN_REPLACEMENT', 'Changed by admin'),
  unknown('', '');

  const PlanSource(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PlanSource fromApi(String value) => values.firstWhere(
    (s) => s.apiValue == value,
    orElse: () => PlanSource.unknown,
  );
}

/// One row from `GET api/v1/subscriptions/me/history`.
class PlanHistoryEntry extends Equatable {
  const PlanHistoryEntry({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.packageCode,
    required this.durationDays,
    required this.status,
    required this.source,
    this.startsAt,
    this.expiresAt,
    this.cancelledAt,
    this.maxResumes,
    this.monthlyApplications,
    this.features = const {},
  });

  final String id;
  final String packageId;
  final String packageName;
  final String packageCode;
  final int durationDays;
  final PlanHistoryStatus status;
  final PlanSource source;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? cancelledAt;
  final int? maxResumes;
  final int? monthlyApplications;
  final Map<String, bool> features;

  bool get isActive => status == PlanHistoryStatus.active;

  /// When the plan stopped (or will stop) applying.
  DateTime? get endedAt => cancelledAt ?? expiresAt;

  /// Enabled feature keys, e.g. `jobAlerts`.
  List<String> get enabledFeatures => [
    for (final e in features.entries)
      if (e.value) e.key,
  ];

  @override
  List<Object?> get props => [id, status, cancelledAt, expiresAt];
}

/// One page of plan history.
class PlanHistoryPage extends Equatable {
  const PlanHistoryPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final List<PlanHistoryEntry> items;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [items, page, totalPages, total];
}
