import 'package:equatable/equatable.dart';

enum PackageType {
  candidate('CANDIDATE'),
  employer('EMPLOYER');

  const PackageType(this.apiValue);

  final String apiValue;
}

/// One way to pay for a package, e.g. ₹499 for 7 days.
class BillingOption extends Equatable {
  const BillingOption({
    required this.id,
    required this.billingPeriod,
    required this.interval,
    required this.durationDays,
    required this.amountMinor,
    required this.currency,
    required this.purchaseAvailable,
  });

  final String id;
  final String billingPeriod;
  final int interval;
  final int durationDays;
  final int amountMinor;
  final String currency;
  final bool purchaseAvailable;

  @override
  List<Object?> get props => [id, amountMinor, durationDays, purchaseAvailable];
}

/// A subscription plan from `GET api/v1/packages`.
class SubscriptionPackage extends Equatable {
  const SubscriptionPackage({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.currency,
    required this.durationDays,
    this.type = '',
    this.status = '',
    this.adminGrantEnabled = false,
    this.packageRequestEnabled = false,
    this.maxResumes,
    this.monthlyApplications,
    this.features = const {},
    this.freeSelectionEnabled = false,
    this.paidCheckoutEnabled = false,
    this.purchaseAvailable = false,
    this.billingOptions = const [],
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final int priceMinor;
  final String currency;
  final int durationDays;

  /// `CANDIDATE` or `EMPLOYER`.
  final String type;

  /// e.g. `ACTIVE`.
  final String status;
  final bool adminGrantEnabled;
  final bool packageRequestEnabled;
  final int? maxResumes;
  final int? monthlyApplications;

  /// Feature flags from `featuresJson`, e.g. `jobAlerts: true`.
  final Map<String, bool> features;
  final bool freeSelectionEnabled;
  final bool paidCheckoutEnabled;
  final bool purchaseAvailable;
  final List<BillingOption> billingOptions;

  /// The billing option a purchase uses: the first one open for purchase.
  /// Null for free plans or when none can be bought right now.
  BillingOption? get billingOption =>
      billingOptions.where((o) => o.purchaseAvailable).firstOrNull;

  /// What the user actually pays, in paise: the billing option's amount,
  /// falling back to the package's own price when there's no option.
  /// Show and charge this, never [priceMinor] directly.
  int get amountMinor => billingOption?.amountMinor ?? priceMinor;

  /// Currency of [amountMinor].
  String get amountCurrency => billingOption?.currency ?? currency;

  /// Days the paid period lasts, from the billing option when there is one.
  int get billingDurationDays {
    final days = billingOption?.durationDays ?? 0;
    return days > 0 ? days : durationDays;
  }

  bool get isFree => amountMinor == 0;

  /// Price in rupees (the API sends paise).
  double get price => amountMinor / 100;

  bool has(String feature) => features[feature] ?? false;

  bool get requiresVerification => has(PackageFeature.verificationRequired);

  @override
  List<Object?> get props => [id, priceMinor, features, billingOptions];
}

/// Known keys in `featuresJson` with their display labels.
abstract final class PackageFeature {
  static const resumeCreation = 'resumeCreation';
  static const jobApplications = 'jobApplications';
  static const jobAlerts = 'jobAlerts';
  static const verifiedBadge = 'verifiedBadge';
  static const verificationRequired = 'verificationRequired';
  static const resumeBuilder = 'resumeBuilder';
  static const profileVisibility = 'profileVisibility';
  static const resumeVisibility = 'resumeVisibility';

  /// Features shown in the comparison, in display order.
  static const displayed = <String, String>{
    resumeCreation: 'Resume builder',
    jobApplications: 'Apply to jobs',
    jobAlerts: 'Job alerts',
    verifiedBadge: 'Verified badge',
    profileVisibility: 'Profile visibility',
    resumeVisibility: 'Resume visibility',
  };
}
