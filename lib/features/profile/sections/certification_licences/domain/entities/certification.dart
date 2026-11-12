import 'package:equatable/equatable.dart';

/// Where a certificate stands today, worked out from its expiry date.
enum CertificationStatus { valid, expiring, expired, noExpiry }

/// A certificate or licence on the signed-in candidate's profile.
class Certification extends Equatable {
  /// A certificate counts as expiring this many days before its expiry date.
  static const expiringWithinDays = 60;

  final String id;
  final String name;
  final String issuingOrganization;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final DateTime? createdAt;

  const Certification({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.createdAt,
  });

  /// Status as of [now] (defaults to today).
  CertificationStatus statusAt([DateTime? now]) {
    final expiry = expiryDate;
    if (expiry == null) return CertificationStatus.noExpiry;
    final today = now ?? DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    if (expiry.isBefore(day)) return CertificationStatus.expired;
    if (expiry.difference(day).inDays <= expiringWithinDays) {
      return CertificationStatus.expiring;
    }
    return CertificationStatus.valid;
  }

  CertificationStatus get status => statusAt();

  bool get needsRenewal =>
      status == CertificationStatus.expiring ||
      status == CertificationStatus.expired;

  @override
  List<Object?> get props => [
    id,
    name,
    issuingOrganization,
    issueDate,
    expiryDate,
    credentialId,
    credentialUrl,
    createdAt,
  ];
}
