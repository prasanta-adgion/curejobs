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
    super.description,
    super.qualificationText,
    super.additionalRequirements,
    super.address,
    super.area,
    super.country,
    super.postalCode,
    super.status,
    super.closedAt,
    super.expiredAt,
    super.pausedAt,
    super.isFeatured,
    super.featuredLabel,
    super.matchReasons,
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
      description: _html(json['description']),
      qualificationText: _text(json['qualificationText']),
      additionalRequirements: _text(json['additionalRequirements']),
      address: _text(json['address']),
      area: _text(json['area']),
      country: _text(json['country']),
      postalCode: _text(json['postalCode']),
      status: JsonParser.nullableString(json['status']),
      closedAt: JsonParser.dateTime(json['closedAt']),
      expiredAt: JsonParser.dateTime(json['expiredAt']),
      pausedAt: JsonParser.dateTime(json['pausedAt']),
      isFeatured: JsonParser.boolean(json['isFeatured']),
      featuredLabel: _text(json['featuredLabel']),
      matchReasons: [
        for (final reason in JsonParser.list(json['matchReasons']))
          if (reason is String && reason.trim().isNotEmpty) reason.trim(),
      ],
    );
  }

  /// Trimmed text, or null when missing or blank.
  static String? _text(Object? value) {
    final text = JsonParser.nullableString(value)?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  /// The API stores the description as entity-encoded HTML
  /// (`&#60;p&#62;` for `<p>`). Decode it back to plain HTML.
  static String? _html(Object? value) {
    final raw = _text(value);
    if (raw == null) return null;
    final html = decodeHtmlEntities(raw);
    // Skip descriptions that are only empty tags.
    final hasText = html.replaceAll(RegExp(r'<[^>]*>'), '').trim().isNotEmpty;
    return hasText ? html : null;
  }

  static const _namedEntities = {
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': ' ',
    'ndash': '–',
    'mdash': '—',
    'rsquo': '’',
    'lsquo': '‘',
    'rdquo': '”',
    'ldquo': '“',
    'hellip': '…',
    'bull': '•',
    'rupee': '₹',
  };

  /// Decodes `&#60;`, `&#x3C;` and named entities like `&amp;`.
  /// Safe to call on text that is already decoded.
  static String decodeHtmlEntities(String input) {
    return input.replaceAllMapped(
      RegExp(r'&(#x[0-9a-fA-F]+|#\d+|[a-zA-Z]+);'),
      (m) {
        final code = m[1]!;
        if (code.startsWith('#x') || code.startsWith('#X')) {
          final n = int.tryParse(code.substring(2), radix: 16);
          return n == null ? m[0]! : String.fromCharCode(n);
        }
        if (code.startsWith('#')) {
          final n = int.tryParse(code.substring(1));
          return n == null ? m[0]! : String.fromCharCode(n);
        }
        return _namedEntities[code.toLowerCase()] ?? m[0]!;
      },
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
