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
    final organization = json['organization'] is Map<String, dynamic>
        ? json['organization'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return JobModel(
      id: json['id'].toString(),
      title: (json['title'] as String? ?? '').trim(),
      slug: json['slug'] as String? ?? '',
      employmentType: _employmentType(json['employmentType'] as String?),
      experienceMinMonths: (json['experienceMinMonths'] as num?)?.toInt(),
      experienceMaxMonths: (json['experienceMaxMonths'] as num?)?.toInt(),
      salaryMinMinor: (json['salaryMinMinor'] as num?)?.toInt(),
      salaryMaxMinor: (json['salaryMaxMinor'] as num?)?.toInt(),
      salaryCurrency: json['salaryCurrency'] as String?,
      salaryPeriod: _salaryPeriod(json['salaryPeriod'] as String?),
      city: json['city'] as String?,
      state: json['state'] as String?,
      publishedAt: _date(json['publishedAt']),
      applicationDeadline: _date(json['applicationDeadline']),
      isSponsored: json['isSponsored'] as bool? ?? false,
      sponsoredLabel: json['sponsoredLabel'] as String?,
      skills: _skills(json['skills']),
      organization: JobOrganization(
        id: (organization['id'] ?? json['organizationId'] ?? '').toString(),
        name: (organization['name'] as String? ?? '').trim(),
        logoFileId: organization['logoFileId'] as String?,
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

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  static String? _name(Object? value) =>
      value is Map<String, dynamic> ? value['name'] as String? : null;

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
