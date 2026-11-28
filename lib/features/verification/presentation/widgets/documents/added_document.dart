import 'package:flutter/material.dart';

import 'package:curejobs/core/services/picked_file.dart';
import 'package:curejobs/features/verification/domain/entities/verification_document_type.dart';

/// A chosen, already-uploaded file and the document type it is for, ready
/// to attach to the request. Passed from [AddDocumentForm] to the page.
class AddedDocument {
  const AddedDocument({
    required this.type,
    required this.file,
    required this.fileId,
  });

  final VerificationDocumentType type;
  final PickedFile file;

  /// Id of the already-uploaded file, sent as `fileId` on submit.
  final String fileId;
}

/// Icon for a document type; unknown codes get a generic file icon.
IconData documentTypeIcon(String code) => switch (code) {
  'IDENTITY_DOCUMENT' => Icons.badge_outlined,
  'PROFESSIONAL_LICENSE' => Icons.workspace_premium_outlined,
  _ => Icons.description_outlined,
};

/// e.g. "820 KB", "1.4 MB".
String formatFileSize(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
