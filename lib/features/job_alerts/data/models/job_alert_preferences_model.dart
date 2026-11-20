import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/job_alert_preferences.dart';

/// Reads and writes `candidates/me/job-alert-preferences`.
abstract final class JobAlertPreferencesModel {
  /// Accepts `{data: {...}}` or the bare object.
  static JobAlertPreferences fromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;

    return JobAlertPreferences(
      enabled: JsonParser.boolean(data['enabled'], fallback: true),
      inAppEnabled: JsonParser.boolean(data['inAppEnabled'], fallback: true),
      emailEnabled: JsonParser.boolean(data['emailEnabled'], fallback: true),
      categoryIds: _strings(data['categoryIds']),
      specializationIds: _strings(data['specializationIds']),
      locations: [
        for (final item in JsonParser.list(data['locations']))
          if (_location(item) case final location?) location,
      ],
      employmentTypes: [
        for (final item in JsonParser.list(data['employmentTypes']))
          if (AlertEmploymentType.fromApi(JsonParser.nullableString(item))
              case final type?)
            type,
      ],
      experienceMinMonths: JsonParser.nullableInteger(
        data['experienceMinMonths'],
      ),
      experienceMaxMonths: JsonParser.nullableInteger(
        data['experienceMaxMonths'],
      ),
      salaryMinMinor: JsonParser.nullableInteger(data['salaryMinMinor']),
      salaryMaxMinor: JsonParser.nullableInteger(data['salaryMaxMinor']),
      salaryCurrency:
          JsonParser.nullableString(data['salaryCurrency']) ?? 'INR',
      updatedAt: JsonParser.dateTime(data['updatedAt']),
    );
  }

  static Map<String, dynamic> toJson(JobAlertPreferences p) => {
    'enabled': p.enabled,
    'inAppEnabled': p.inAppEnabled,
    'emailEnabled': p.emailEnabled,
    'categoryIds': p.categoryIds,
    'specializationIds': p.specializationIds,
    'locations': [
      for (final l in p.locations)
        {
          if (l.city != null) 'city': l.city,
          if (l.state != null) 'state': l.state,
        },
    ],
    'employmentTypes': [for (final t in p.employmentTypes) t.apiValue],
    'experienceMinMonths': p.experienceMinMonths,
    'experienceMaxMonths': p.experienceMaxMonths,
    'salaryMinMinor': p.salaryMinMinor,
    'salaryMaxMinor': p.salaryMaxMinor,
    'salaryCurrency': p.salaryCurrency,
  };

  static List<String> _strings(Object? json) => [
    for (final item in JsonParser.list(json))
      if (JsonParser.nullableString(item) case final s? when s.isNotEmpty) s,
  ];

  static AlertLocation? _location(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    String? clean(Object? v) {
      final s = JsonParser.nullableString(v)?.trim();
      return s == null || s.isEmpty ? null : s;
    }

    final city = clean(json['city']);
    final state = clean(json['state']);
    if (city == null && state == null) return null;
    return AlertLocation(city: city, state: state);
  }
}
