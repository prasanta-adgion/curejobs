import 'package:equatable/equatable.dart';

import '../../../domain/entities/candidate.dart';

/// Values on the Edit profile form. Compared with the starting values to know
/// whether there are unsaved changes.
class ProfileEditData extends Equatable {
  const ProfileEditData({
    required this.firstName,
    required this.lastName,
    required this.professionalTitle,
    required this.professionalSummary,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.categoryId,
    this.specializationId,
  });

  factory ProfileEditData.fromCandidate(Candidate candidate) {
    return ProfileEditData(
      firstName: candidate.firstName,
      lastName: candidate.lastName,
      professionalTitle: candidate.professionalTitle ?? '',
      professionalSummary: candidate.professionalSummary ?? '',
      address: candidate.address ?? '',
      city: candidate.city ?? '',
      state: candidate.state ?? '',
      country: candidate.country ?? '',
      postalCode: candidate.postalCode ?? '',
      categoryId: candidate.primaryCategoryId,
      specializationId: candidate.primarySpecializationId,
    );
  }

  final String firstName;
  final String lastName;
  final String professionalTitle;
  final String professionalSummary;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? categoryId;
  final String? specializationId;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    professionalTitle,
    professionalSummary,
    address,
    city,
    state,
    country,
    postalCode,
    categoryId,
    specializationId,
  ];
}

/// A category the candidate can pick, with its specializations.
class ProfileCategoryOption extends Equatable {
  const ProfileCategoryOption({
    required this.id,
    required this.name,
    this.specializations = const [],
  });

  final String id;
  final String name;
  final List<ProfileSpecializationOption> specializations;

  @override
  List<Object?> get props => [id, name, specializations];
}

class ProfileSpecializationOption extends Equatable {
  const ProfileSpecializationOption({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
