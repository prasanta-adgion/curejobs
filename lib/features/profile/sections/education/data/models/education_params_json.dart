import '../../domain/entities/education_params.dart';

/// Request body for creating or updating education.
extension EducationParamsJson on EducationParams {
  Map<String, dynamic> toJson() {
    String? text(String value) => value.trim().isEmpty ? null : value.trim();

    return {
      'degree': degree.trim(),
      'institution': institution.trim(),
      'fieldOfStudy': text(fieldOfStudy),
      'startYear': startYear,
      'completionYear': currentlyStudying ? null : completionYear,
      'currentlyStudying': currentlyStudying,
      'description': text(description),
    };
  }
}
