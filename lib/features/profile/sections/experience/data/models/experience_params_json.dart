import '../../domain/entities/experience_params.dart';

/// Request body for creating or updating a position.
extension ExperienceParamsJson on ExperienceParams {
  Map<String, dynamic> toJson() {
    String? text(String value) => value.trim().isEmpty ? null : value.trim();

    return {
      'jobTitle': jobTitle.trim(),
      'organizationName': organizationName.trim(),
      'employmentType': employmentType?.apiValue,
      'startDate': _date(startDate),
      'endDate': currentlyWorking ? null : _date(endDate),
      'currentlyWorking': currentlyWorking,
      'location': text(location),
      'responsibilities': text(responsibilities),
    };
  }

  /// `yyyy-MM-dd`, as the API returns it.
  static String? _date(DateTime? d) {
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}
