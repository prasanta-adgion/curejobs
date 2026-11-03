import 'package:equatable/equatable.dart';

/// The signed-in candidate's own profile, as the app uses it.
class Candidate extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? professionalTitle;
  final String? professionalSummary;
  final String? profilePhotoFileId;
  final String? primaryCategoryId;
  final String? primarySpecializationId;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  /// From 0 to 100.
  final int profileCompletionPercent;
  final CandidateVerification verification;

  const Candidate({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.professionalTitle,
    this.professionalSummary,
    this.profilePhotoFileId,
    this.primaryCategoryId,
    this.primarySpecializationId,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.profileCompletionPercent = 0,
    this.verification = const CandidateVerification(),
  });

  String get fullName => [
    firstName,
    lastName,
  ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(' ');

  /// Up to two letters: first letter of the first and last name.
  String get initials {
    final letters = [firstName, lastName]
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase());
    return letters.isEmpty ? '?' : letters.join();
  }

  /// "Kolkata, West Bengal", or whichever parts are known.
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
    address,
    city,
    state,
    country,
    postalCode,
    profileCompletionPercent,
    verification,
  ];
}

enum DocumentStatus { notSubmitted, pending, approved, rejected }

/// Document review result and the verified badge it earns.
class CandidateVerification extends Equatable {
  final DocumentStatus documentStatus;
  final bool badgeActive;
  final String? badgeSource;
  final DateTime? badgeExpiresAt;

  const CandidateVerification({
    this.documentStatus = DocumentStatus.notSubmitted,
    this.badgeActive = false,
    this.badgeSource,
    this.badgeExpiresAt,
  });

  /// Show the verified badge only while it is active and not expired.
  bool isVerifiedAt(DateTime now) {
    if (!badgeActive || documentStatus != DocumentStatus.approved) {
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
    badgeExpiresAt,
  ];
}
