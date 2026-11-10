import 'package:flutter/material.dart';

import '../../../core/widgets/app_snackbar.dart';

import '../../../core/services/picked_file.dart';
import '../domain/entities/media_complete_data.dart';
import '../domain/enums/media_upload_purpose.dart';
import 'pages/media_preview_page.dart';
import 'pages/media_upload_page.dart';

/// Picks a file, previews it, then uploads it. Picking again runs [picker]
/// once more. Null if the user cancels.
Future<({PickedFile file, String fileId})?> pickAndUploadMedia(
  BuildContext context,
  Future<PickedFile?> Function() picker, {
  required MediaUploadPurpose purpose,
  String pickAgainLabel = 'Change',
  String? name,
  String? subtitle,
}) async {
  while (context.mounted) {
    final file = await _pick(context, picker);
    if (file == null || !context.mounted) return null;

    final result = await Navigator.of(context).push<MediaPreviewResult>(
      MaterialPageRoute(
        builder: (_) => MediaPreviewPage(
          file: file,
          pickAgainLabel: pickAgainLabel,
          name: name,
          subtitle: subtitle,
        ),
      ),
    );
    if (result == null) return null;

    final selected = result.file;
    if (selected == null || !context.mounted) continue;

    final uploaded = await Navigator.of(context).push<MediaCompleteData>(
      MaterialPageRoute(
        builder: (_) => MediaUploadPage(file: selected, purpose: purpose),
      ),
    );
    if (uploaded == null) return null;
    return (file: selected, fileId: uploaded.fileId);
  }
  return null;
}

/// Runs [picker] and shows why a file was rejected. Null if none was chosen.
Future<PickedFile?> _pick(
  BuildContext context,
  Future<PickedFile?> Function() picker,
) async {
  try {
    return await picker();
  } on PickedFileException catch (error) {
    AppSnackbar.error(title: error.message);
    return null;
  }
}
