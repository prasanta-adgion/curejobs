import '../../domain/entities/certification_params.dart';

/// Request body for creating or updating a certificate.
extension CertificationParamsJson on CertificationParams {
  Map<String, dynamic> toJson() {
    String? text(String value) => value.trim().isEmpty ? null : value.trim();

    return {
      'name': name.trim(),
      'issuingOrganization': issuingOrganization.trim(),
      'issueDate': _date(issueDate),
      'expiryDate': doesNotExpire ? null : _date(expiryDate),
      'credentialId': text(credentialId),
      'credentialUrl': text(credentialUrl),
    };
  }

  /// `yyyy-MM-dd`, as the API returns it.
  static String? _date(DateTime? d) {
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}
