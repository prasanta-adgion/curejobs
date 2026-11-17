import 'package:flutter/material.dart';

import '../../../core/services/document_picker_service.dart';
import '../../../core/services/picked_file.dart';
import '../domain/enums/media_upload_purpose.dart';
import 'pick_and_upload_media.dart';

/// Opens the device's files straight away to pick a CV (PDF, DOC, DOCX),
/// previews it, then uploads it to S3. Returns the file and its `fileId`,
/// or null if the user cancels. Usable from any screen.
Future<({PickedFile file, String fileId})?> pickAndUploadDocument(
  BuildContext context, {
  MediaUploadPurpose purpose = MediaUploadPurpose.resume,
}) {
  return pickAndUploadMedia(
    context,
    () => const DocumentPickerService().pickResume(),
    purpose: purpose,
    pickAgainLabel: 'Choose another',
  );
}
