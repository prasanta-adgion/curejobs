import 'dart:io';

import 'package:curejobs/core/constants/app_icons.dart';
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

  /// The file to upload, or null if the user wants to pick another.
  final PickedFile? file;
}

/// Shows the file the user just picked. Images can be cropped first, and the
/// preview then shows the cropped photo. Pops with a [MediaPreviewResult], or
/// null if cancelled.
class MediaPreviewPage extends StatefulWidget {
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

  @override
  State<MediaPreviewPage> createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  /// The picked file, or its cropped version.
  late final _file = ValueNotifier<PickedFile>(widget.file);

  @override
  void dispose() {
    _file.dispose();
    super.dispose();
  }

  Future<void> _crop() async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<CropImageResult>(
      MaterialPageRoute(
        builder: (_) => CropImagePage(
          path: _file.value.path,
          retakeLabel: widget.pickAgainLabel,
          name: widget.name,
          subtitle: widget.subtitle,
        ),
      ),
    );
    // Cancelling the crop keeps the current preview.
    if (result == null || !mounted) return;

    final cropped = result.file;
    if (cropped == null) {
      navigator.pop(const MediaPreviewResult.pickAgain());
    } else {
      _file.value = cropped;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: ValueListenableBuilder<PickedFile>(
            valueListenable: _file,
            builder: (context, file, _) {
              final type = MediaFileType.of(file);
              final isImage = type == MediaFileType.image;

              return Column(
                children: [
                  CropTopBar(
                    title: 'Preview',
                    subtitle: type.label,
                    icon: AppIcons.close,
                    tooltip: 'Cancel',
                    onLeading: navigator.pop,
                  ),
                  Expanded(
                    child: isImage
                        ? ImagePreview(file: File(file.path))
                        : DocumentPreview(file: file, type: type),
                  ),
                  if (isImage)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: OutlinedButton.icon(
                        onPressed: _crop,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkTextPrimary,
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(
                            color: AppColors.darkInputBorder,
                          ),
                        ),
                        icon: const Icon(
                          Icons.crop_rounded,
                          size: 18,
                          color: AppColors.darkPrimary,
                        ),
                        label: const Text('Crop image'),
                      ),
                    ),
                  CropActions(
                    secondaryLabel: widget.pickAgainLabel,
                    primaryLabel: 'Upload',
                    onSecondary: () =>
                        navigator.pop(const MediaPreviewResult.pickAgain()),
                    onPrimary: () =>
                        navigator.pop(MediaPreviewResult.selected(file)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
