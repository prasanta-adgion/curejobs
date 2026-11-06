enum MediaUploadPurpose {
  profilePhoto('PROFILE_PHOTO'),
  resume('RESUME'),
  verificationDocument('VERIFICATION_DOCUMENT');

  const MediaUploadPurpose(this.apiValue);

  final String apiValue;
}
