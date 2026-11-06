import 'package:equatable/equatable.dart';

class Candidate extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? professionalTitle;
  final String? professionalSummary;
  final String? profilePhotoFileId;
  final String? primaryCategoryId;
  final String? primarySpecializationId;

  final String? area;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  final int profileCompletionPercent;
  final CandidateVerification verification;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Candidate({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.professionalTitle,
    this.professionalSummary,
    this.profilePhotoFileId,
    this.primaryCategoryId,
    this.primarySpecializationId,
    this.area,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.profileCompletionPercent = 0,
    this.verification = const CandidateVerification(),
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => [
    firstName,
    lastName,
  ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');

  String get initials {
    final letters = [firstName, lastName]
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2);

    return letters.isEmpty ? '?' : letters.join();
  }

  String? get location {
    final parts = [city, state]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map(_capitalise)
        .toList();

    return parts.isEmpty ? null : parts.join(', ');
  }

  bool get isProfileComplete => profileCompletionPercent >= 100;

  static String _capitalise(String value) => value
      .split(' ')
      .map(
        (word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
      )
      .join(' ');

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    professionalTitle,
    professionalSummary,
    profilePhotoFileId,
    primaryCategoryId,
    primarySpecializationId,
    area,
    address,
    city,
    state,
    country,
    postalCode,
    profileCompletionPercent,
    verification,
    createdAt,
    updatedAt,
  ];
}

enum DocumentStatus { notSubmitted, pending, approved, rejected }

class CandidateVerification extends Equatable {
  final DocumentStatus documentStatus;
  final bool badgeActive;
  final String? badgeSource;
  final String? badgeKind;
  final String? badgeCollegeName;
  final DateTime? badgeExpiresAt;

  const CandidateVerification({
    this.documentStatus = DocumentStatus.notSubmitted,
    this.badgeActive = false,
    this.badgeSource,
    this.badgeKind,
    this.badgeCollegeName,
    this.badgeExpiresAt,
  });

  bool get isDocumentApproved => documentStatus == DocumentStatus.approved;

  bool isVerifiedAt(DateTime now) {
    if (!badgeActive || !isDocumentApproved) {
      return false;
    }

    final expiresAt = badgeExpiresAt;

    return expiresAt == null || expiresAt.isAfter(now);
  }

  @override
  List<Object?> get props => [
    documentStatus,
    badgeActive,
    badgeSource,
    badgeKind,
    badgeCollegeName,
    badgeExpiresAt,
  ];
}
