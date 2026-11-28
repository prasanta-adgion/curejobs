import 'package:equatable/equatable.dart';

enum PackageType {
  candidate('CANDIDATE'),
  employer('EMPLOYER');

  const PackageType(this.apiValue);

  final String apiValue;
}

/// What the user can do with a package, decided by the API flags.
enum PlanAction {
  /// Free plan: select it directly.
  select,

  /// Paid plan with online checkout open: pay with Razorpay.
  buy,

  /// Online payment is off but requests are open: ask admin for it.
  request,

  /// Requests are enabled but closed for this user right now (e.g. a
  /// request is already pending).
  requestPending,

  /// Nothing possible right now.
  unavailable,
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
    this.selectedBillingOptionId,
    this.billingPeriod,
    this.providerPlanConfigured = false,
    this.requestAvailable = false,
    this.contactAvailable = false,
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

  /// The package can be requested from admin instead of paid online.
  final bool packageRequestEnabled;
  final int? maxResumes;
  final int? monthlyApplications;

  /// Feature flags from `featuresJson`, e.g. `jobAlerts: true`.
  final Map<String, bool> features;
  final bool freeSelectionEnabled;

  /// Online payment is switched on for this package.
  final bool paidCheckoutEnabled;
  final bool purchaseAvailable;
  final List<BillingOption> billingOptions;
  final String? selectedBillingOptionId;

  /// e.g. `MONTHLY`; null for free plans.
  final String? billingPeriod;

  /// The payment provider (Razorpay) has a plan set up for this package.
  final bool providerPlanConfigured;

  /// The user may send a request for this package right now.
  final bool requestAvailable;

  /// Support can be contacted about this package.
  final bool contactAvailable;

  /// The billing option shown and charged: the selected one if set, else
  /// the first open for purchase, else the first one (so request-only
  /// plans still show their price). Null when there are none.
  ///
  /// Whether it can actually be bought is [canPurchase].
  BillingOption? get billingOption {
    final selectedId = selectedBillingOptionId;
    if (selectedId != null) {
      final selected = billingOptions.where((o) => o.id == selectedId);
      if (selected.isNotEmpty) return selected.first;
    }
    return billingOptions.where((o) => o.purchaseAvailable).firstOrNull ??
        billingOptions.firstOrNull;
  }

  SubscriptionPackage withBillingOption(String? id) => SubscriptionPackage(
    id: this.id,
    code: code,
    name: name,
    description: description,
    priceMinor: priceMinor,
    currency: currency,
    durationDays: durationDays,
    type: type,
    status: status,
    adminGrantEnabled: adminGrantEnabled,
    packageRequestEnabled: packageRequestEnabled,
    maxResumes: maxResumes,
    monthlyApplications: monthlyApplications,
    features: features,
    freeSelectionEnabled: freeSelectionEnabled,
    paidCheckoutEnabled: paidCheckoutEnabled,
    purchaseAvailable: purchaseAvailable,
    billingOptions: billingOptions,
    selectedBillingOptionId: id,
    billingPeriod: billingPeriod,
    providerPlanConfigured: providerPlanConfigured,
    requestAvailable: requestAvailable,
    contactAvailable: contactAvailable,
  );

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

  /// A free plan the user may pick directly.
  bool get canSelectFree => isFree && freeSelectionEnabled && purchaseAvailable;

  /// A paid plan that can be bought online right now: checkout is on, the
  /// Razorpay plan exists, and the package and its billing option are
  /// open for purchase. The server re-checks on purchase anyway.
  bool get canPurchase {
    final option = billingOption;
    return !isFree &&
        paidCheckoutEnabled &&
        providerPlanConfigured &&
        purchaseAvailable &&
        option != null &&
        option.purchaseAvailable;
  }

  /// Paid plan that can't be bought online but accepts admin requests.
  bool get isRequestOnly => !isFree && !canPurchase && packageRequestEnabled;

  /// The user can send a request for this package right now.
  bool get canRequest => isRequestOnly && requestAvailable;

  /// What the main button does for this package.
  PlanAction get action {
    if (isFree) {
      return canSelectFree ? PlanAction.select : PlanAction.unavailable;
    }
    if (canPurchase) return PlanAction.buy;
    if (canRequest) return PlanAction.request;
    if (isRequestOnly) return PlanAction.requestPending;
    return PlanAction.unavailable;
  }

  /// Price in rupees (the API sends paise).
  double get price => amountMinor / 100;

  bool has(String feature) => features[feature] ?? false;

  bool get requiresVerification => has(PackageFeature.verificationRequired);

  @override
  List<Object?> get props => [
    id,
    priceMinor,
    features,
    billingOptions,
    selectedBillingOptionId,
    freeSelectionEnabled,
    paidCheckoutEnabled,
    purchaseAvailable,
    providerPlanConfigured,
    packageRequestEnabled,
    requestAvailable,
    contactAvailable,
  ];
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
