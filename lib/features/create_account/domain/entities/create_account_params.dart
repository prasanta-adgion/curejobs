import 'package:equatable/equatable.dart';

/// Everything collected by the create account flow, sent in one save.
class CreateAccountParams extends Equatable {
  final String firstName;
  final String lastName;
  final String? professionalTitle;
  final String? professionalSummary;

  /// From the completed profile photo upload.
  final String? profilePhotoFileId;
  final String? primaryCategoryId;
  final String? primarySpecializationId;
  final String? area;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  const CreateAccountParams({
    required this.firstName,
    required this.lastName,
    this.professionalTitle,
    this.professionalSummary,
    this.profilePhotoFileId,
    this.primaryCategoryId,
    this.primarySpecializationId,
    this.area,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    professionalTitle,
    professionalSummary,
    profilePhotoFileId,
    primaryCategoryId,
    primarySpecializationId,
    area,
    city,
    state,
    country,
    postalCode,
  ];
}
