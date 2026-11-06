import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The whole picked photo. Pinch to zoom.
class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.file});

  /// Longest side kept in memory, so a large photo can't exhaust it.
  static const _maxDecodedSide = 2048;

  final File file;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 4,
      child: Center(
        child: Image(
          image: ResizeImage(
            FileImage(file),
            width: _maxDecodedSide,
            height: _maxDecodedSide,
            policy: ResizeImagePolicy.fit,
          ),
          fit: BoxFit.contain,
          errorBuilder: (context, _, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "That photo couldn't be opened. Try another one.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.darkTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
