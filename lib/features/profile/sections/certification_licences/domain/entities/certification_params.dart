import 'package:equatable/equatable.dart';

/// What the candidate enters when adding or editing a certificate.
class CertificationParams extends Equatable {
  final String name;
  final String issuingOrganization;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final bool doesNotExpire;
  final String credentialId;
  final String credentialUrl;

  const CertificationParams({
    this.name = '',
    this.issuingOrganization = '',
    this.issueDate,
    this.expiryDate,
    this.doesNotExpire = false,
    this.credentialId = '',
    this.credentialUrl = '',
  });

  @override
  List<Object?> get props => [
    name,
    issuingOrganization,
    issueDate,
    expiryDate,
    doesNotExpire,
    credentialId,
    credentialUrl,
  ];
}
