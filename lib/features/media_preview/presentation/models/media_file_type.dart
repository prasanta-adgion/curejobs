import 'package:flutter/material.dart';

import '../../../../core/services/picked_file.dart';

/// What a picked file is, worked out from its extension.
enum MediaFileType {
  image('Image', Icons.image_outlined),
  pdf('PDF document', Icons.picture_as_pdf_outlined),
  word('Word document', Icons.description_outlined),
  other('File', Icons.insert_drive_file_outlined);

  const MediaFileType(this.label, this.icon);

  final String label;
  final IconData icon;

  factory MediaFileType.of(PickedFile file) {
    final name = file.name.toLowerCase();
    final extension = name.contains('.') ? name.split('.').last : '';

    return switch (extension) {
      'png' || 'jpg' || 'jpeg' || 'webp' => MediaFileType.image,
      'pdf' => MediaFileType.pdf,
      'doc' || 'docx' => MediaFileType.word,
      _ => MediaFileType.other,
    };
  }
}
