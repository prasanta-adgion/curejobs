import 'package:equatable/equatable.dart';

enum EmploymentType {
  fullTime,
  partTime,
  contract,
  temporary,
  internship,
  freelance,
  other,
}

enum SalaryPeriod { hourly, daily, weekly, monthly, yearly }

/// A published job listing.
class Job extends Equatable {
  final String id;
  final String title;
  final String slug;
  final EmploymentType employmentType;
  final int? experienceMinMonths;
  final int? experienceMaxMonths;

  /// Salary in the currency's minor unit (paise for INR).
  final int? salaryMinMinor;
  final int? salaryMaxMinor;
  final String? salaryCurrency;
  final SalaryPeriod? salaryPeriod;
  final String? city;
  final String? state;
  final DateTime? publishedAt;
  final DateTime? applicationDeadline;
  final bool isSponsored;
  final String? sponsoredLabel;
  final List<String> skills;
  final JobOrganization organization;
  final String? categoryName;
  final String? specializationName;

  /// Job description as HTML (entities already decoded).
  final String? description;
  final String? qualificationText;
  final String? additionalRequirements;
  final String? address;
  final String? area;
  final String? country;
  final String? postalCode;

  /// API status, e.g. `PUBLISHED`, `PAUSED`, `CLOSED`, `EXPIRED`.
  final String? status;
  final DateTime? closedAt;
  final DateTime? expiredAt;
  final DateTime? pausedAt;
  final bool isFeatured;
  final String? featuredLabel;

  /// Why this job was recommended, e.g. "Near you: Kolkata".
  final List<String> matchReasons;

  const Job({
    required this.id,
    required this.title,
    required this.slug,
    required this.employmentType,
    required this.organization,
    this.experienceMinMonths,
    this.experienceMaxMonths,
    this.salaryMinMinor,
    this.salaryMaxMinor,
    this.salaryCurrency,
    this.salaryPeriod,
    this.city,
    this.state,
    this.publishedAt,
    this.applicationDeadline,
    this.isSponsored = false,
    this.sponsoredLabel,
    this.skills = const [],
    this.categoryName,
    this.specializationName,
    this.description,
    this.qualificationText,
    this.additionalRequirements,
    this.address,
    this.area,
    this.country,
    this.postalCode,
    this.status,
    this.closedAt,
    this.expiredAt,
    this.pausedAt,
    this.isFeatured = false,
    this.featuredLabel,
    this.matchReasons = const [],
  });

  bool get hasSalary => salaryMinMinor != null || salaryMaxMinor != null;

  /// Not accepting applications: paused, closed, expired, or status says so.
  bool get isClosed {
    final s = status?.toUpperCase();
    return closedAt != null ||
        expiredAt != null ||
        pausedAt != null ||
        (s != null && s != 'PUBLISHED');
  }

  /// Published within the last 24 hours of [now].
  bool isNewAt(DateTime now) {
    final published = publishedAt;
    return published != null && now.difference(published).inHours < 24;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    employmentType,
    experienceMinMonths,
    experienceMaxMonths,
    salaryMinMinor,
    salaryMaxMinor,
    salaryCurrency,
    salaryPeriod,
    city,
    state,
    publishedAt,
    applicationDeadline,
    isSponsored,
    sponsoredLabel,
    skills,
    organization,
    categoryName,
    specializationName,
    description,
    qualificationText,
    additionalRequirements,
    address,
    area,
    country,
    postalCode,
    status,
    closedAt,
    expiredAt,
    pausedAt,
    isFeatured,
    featuredLabel,
    matchReasons,
  ];
}

/// The employer that posted a job.
class JobOrganization extends Equatable {
  final String id;
  final String name;
  final String? logoFileId;

  const JobOrganization({
    required this.id,
    required this.name,
    this.logoFileId,
  });

  @override
  List<Object?> get props => [id, name, logoFileId];
}
