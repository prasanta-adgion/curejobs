import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.employmentType,
    required super.organization,
    super.experienceMinMonths,
    super.experienceMaxMonths,
    super.salaryMinMinor,
    super.salaryMaxMinor,
    super.salaryCurrency,
    super.salaryPeriod,
    super.city,
    super.state,
    super.publishedAt,
    super.applicationDeadline,
    super.isSponsored,
    super.sponsoredLabel,
    super.skills,
    super.categoryName,
    super.specializationName,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final organization = JsonParser.map(json['organization']);

    return JobModel(
      id: JsonParser.string(json['id']),
      title: JsonParser.string(json['title']).trim(),
      slug: JsonParser.string(json['slug']),
      employmentType: _employmentType(
        JsonParser.nullableString(json['employmentType']),
      ),
      experienceMinMonths: JsonParser.nullableInteger(
        json['experienceMinMonths'],
      ),
      experienceMaxMonths: JsonParser.nullableInteger(
        json['experienceMaxMonths'],
      ),
      salaryMinMinor: JsonParser.nullableInteger(json['salaryMinMinor']),
      salaryMaxMinor: JsonParser.nullableInteger(json['salaryMaxMinor']),
      salaryCurrency: JsonParser.nullableString(json['salaryCurrency']),
      salaryPeriod: _salaryPeriod(
        JsonParser.nullableString(json['salaryPeriod']),
      ),
      city: JsonParser.nullableString(json['city']),
      state: JsonParser.nullableString(json['state']),
      publishedAt: JsonParser.dateTime(json['publishedAt']),
      applicationDeadline: JsonParser.dateTime(json['applicationDeadline']),
      isSponsored: JsonParser.boolean(json['isSponsored']),
      sponsoredLabel: JsonParser.nullableString(json['sponsoredLabel']),
      skills: _skills(json['skills']),
      organization: JobOrganization(
        id: JsonParser.string(organization['id'] ?? json['organizationId']),
        name: JsonParser.string(organization['name']).trim(),
        logoFileId: JsonParser.nullableString(organization['logoFileId']),
      ),
      categoryName: _name(json['category']),
      specializationName: _name(json['specialization']),
    );
  }

  static EmploymentType _employmentType(String? value) =>
      switch (value?.toUpperCase()) {
        'FULL_TIME' => EmploymentType.fullTime,
        'PART_TIME' => EmploymentType.partTime,
        'CONTRACT' => EmploymentType.contract,
        'TEMPORARY' => EmploymentType.temporary,
        'INTERNSHIP' => EmploymentType.internship,
        'FREELANCE' => EmploymentType.freelance,
        _ => EmploymentType.other,
      };

  static SalaryPeriod? _salaryPeriod(String? value) =>
      switch (value?.toUpperCase()) {
        'HOURLY' => SalaryPeriod.hourly,
        'DAILY' => SalaryPeriod.daily,
        'WEEKLY' => SalaryPeriod.weekly,
        'MONTHLY' => SalaryPeriod.monthly,
        'YEARLY' || 'ANNUAL' || 'ANNUALLY' => SalaryPeriod.yearly,
        _ => null,
      };

  static String? _name(Object? value) =>
      JsonParser.nullableString(JsonParser.map(value)['name']);

  /// Skills may come as plain strings or as `{name: ...}` objects.
  static List<String> _skills(Object? value) {
    if (value is! List) return const [];
    return [
      for (final skill in value)
        if (skill is String)
          skill
        else if (skill is Map<String, dynamic> && skill['name'] is String)
          skill['name'] as String,
    ];
  }
}
