import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/picked_file.dart';
import '../../../crop_image/presentation/pages/crop_image_page.dart';
import '../../../crop_image/presentation/widgets/crop_controls.dart';
import '../models/media_file_type.dart';
import '../widgets/document_preview.dart';
import '../widgets/image_preview.dart';

/// What the user decided on the preview screen.
class MediaPreviewResult {
  const MediaPreviewResult.selected(PickedFile this.file);
  const MediaPreviewResult.pickAgain() : file = null;

  /// The file to use, or null if the user wants to pick another.
  final PickedFile? file;
}

/// Shows the file the user just picked. Images go on to the crop screen;
/// documents can be used as they are. Pops with a [MediaPreviewResult], or
/// null if cancelled.
class MediaPreviewPage extends StatelessWidget {
  const MediaPreviewPage({
    super.key,
    required this.file,
    this.pickAgainLabel = 'Change',
    this.name,
    this.subtitle,
  });

  final PickedFile file;
  final String pickAgainLabel;

  /// Passed to the crop screen's preview, when known.
  final String? name;
  final String? subtitle;

  Future<void> _crop(BuildContext context) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<CropImageResult>(
      MaterialPageRoute(
        builder: (_) => CropImagePage(
          path: file.path,
          retakeLabel: pickAgainLabel,
          name: name,
          subtitle: subtitle,
        ),
      ),
    );
    // Cancelling the crop comes back to this preview.
    if (result == null || !context.mounted) return;

    final cropped = result.file;
    navigator.pop(
      cropped == null
          ? const MediaPreviewResult.pickAgain()
          : MediaPreviewResult.selected(cropped),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = MediaFileType.of(file);
    final isImage = type == MediaFileType.image;
    final navigator = Navigator.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Column(
            children: [
              CropTopBar(
                title: 'Preview',
                subtitle: type.label,
                icon: Icons.close_rounded,
                tooltip: 'Cancel',
                onLeading: navigator.pop,
              ),
              Expanded(
                child: isImage
                    ? ImagePreview(file: File(file.path))
                    : DocumentPreview(file: file, type: type),
              ),
              CropActions(
                secondaryLabel: pickAgainLabel,
                primaryLabel: isImage ? 'Crop image' : 'Use this file',
                onSecondary: () =>
                    navigator.pop(const MediaPreviewResult.pickAgain()),
                onPrimary: isImage
                    ? () => _crop(context)
                    : () => navigator.pop(MediaPreviewResult.selected(file)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
