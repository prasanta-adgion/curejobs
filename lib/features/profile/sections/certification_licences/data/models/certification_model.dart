import '../../../../../../core/utils/json_parser.dart';
import '../../domain/entities/certification.dart';

class CertificationModel extends Certification {
  const CertificationModel({
    required super.id,
    required super.name,
    required super.issuingOrganization,
    super.issueDate,
    super.expiryDate,
    super.credentialId,
    super.credentialUrl,
    super.createdAt,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: JsonParser.string(json['id']),
      name: JsonParser.string(json['name']).trim(),
      issuingOrganization: JsonParser.string(json['issuingOrganization'])
          .trim(),
      issueDate: JsonParser.dateTime(json['issueDate']),
      expiryDate: JsonParser.dateTime(json['expiryDate']),
      credentialId: JsonParser.nullableString(json['credentialId']),
      credentialUrl: JsonParser.nullableString(json['credentialUrl']),
      createdAt: JsonParser.dateTime(json['createdAt']),
    );
  }

  /// Reads `{data: {items: [...]}}`. Ones needing renewal come first, then
  /// the rest by expiry date (soonest first, no expiry last).
  static List<CertificationModel> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = JsonParser.map(root['data']);
    final items = JsonParser.list(data['items']);

    final list = [
      for (final item in items)
        if (item is Map<String, dynamic>) CertificationModel.fromJson(item),
    ].where((c) => c.name.isNotEmpty).toList();

    int rank(Certification c) => c.needsRenewal ? 0 : 1;
    list.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final ae = a.expiryDate;
      final be = b.expiryDate;
      if (ae == null && be == null) return 0;
      if (ae == null) return 1;
      if (be == null) return -1;
      return ae.compareTo(be);
    });
    return list;
  }
}
