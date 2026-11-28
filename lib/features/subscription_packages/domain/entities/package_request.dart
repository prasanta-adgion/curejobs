import 'package:equatable/equatable.dart';

/// Status of a request to admin for a package.
enum PackageRequestStatusType {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  unknown('');

  const PackageRequestStatusType(this.apiValue);

  final String apiValue;

  static PackageRequestStatusType fromApi(String value) {
    final upper = value.toUpperCase();
    return values.firstWhere(
      (s) => s != unknown && s.apiValue == upper,
      orElse: () => unknown,
    );
  }
}

/// The short package summary embedded in a request.
class RequestedPackage extends Equatable {
  const RequestedPackage({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.durationDays,
    required this.priceMinor,
    required this.currency,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final String type;
  final int durationDays;
  final int priceMinor;
  final String currency;

  @override
  List<Object?> get props => [id, code, name, priceMinor, durationDays];
}

/// One request from `GET api/v1/subscriptions/me/package-requests`.
class PackageRequest extends Equatable {
  const PackageRequest({
    required this.id,
    required this.packageId,
    required this.status,
    this.message,
    this.reviewReason,
    this.subscriptionId,
    this.createdAt,
    this.reviewedAt,
    this.updatedAt,
    this.package,
  });

  final String id;
  final String packageId;
  final PackageRequestStatusType status;
  final String? message;

  /// Admin's reason, mostly set when the request is rejected.
  final String? reviewReason;

  /// Set once approved and a subscription was granted.
  final String? subscriptionId;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final DateTime? updatedAt;
  final RequestedPackage? package;

  bool get isPending => status == PackageRequestStatusType.pending;
  bool get isApproved => status == PackageRequestStatusType.approved;
  bool get isRejected => status == PackageRequestStatusType.rejected;

  /// Name to show, falling back when the API leaves out the package.
  String get packageName => package?.name ?? 'this plan';

  @override
  List<Object?> get props => [id, packageId, status, reviewReason, updatedAt];
}
