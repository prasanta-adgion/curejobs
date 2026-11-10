import '../../domain/entities/create_account_params.dart';

/// Body of `PUT api/v1/candidates/me` during account creation.
class CreateAccountRequestModel {
  final CreateAccountParams params;

  const CreateAccountRequestModel(this.params);

  /// Strings are trimmed; blank ones are sent as null.
  Map<String, dynamic> toJson() => {
    'firstName': params.firstName.trim(),
    'lastName': params.lastName.trim(),
    'professionalTitle': _clean(params.professionalTitle),
    'professionalSummary': _clean(params.professionalSummary),
    'profilePhotoFileId': _clean(params.profilePhotoFileId),
    'primaryCategoryId': _clean(params.primaryCategoryId),
    'primarySpecializationId': _clean(params.primarySpecializationId),
    'area': _clean(params.area),
    'city': _clean(params.city),
    'state': _clean(params.state),
    'country': _clean(params.country),
    'postalCode': _clean(params.postalCode),
  };

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
