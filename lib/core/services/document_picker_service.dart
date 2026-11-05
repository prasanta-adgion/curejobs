import 'package:file_picker/file_picker.dart';

import 'picked_file.dart';

/// Lets the user choose a resume from their device.
class DocumentPickerService {
  const DocumentPickerService();

  static const _allowedExtensions = {'pdf', 'doc', 'docx'};
  static const _maxSizeInBytes = 5 * 1024 * 1024;

  /// Returns the chosen resume, or null if the user cancels. Throws
  /// [PickedFileException] if the file type or size is not allowed.
  Future<PickedFile?> pickResume() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions.toList(),
    );
    if (files.isEmpty) return null;

    final selected = files.first;
    final path = selected.path;
    if (path == null) {
      throw const PickedFileException("That file couldn't be opened.");
    }

    final size = await selected.length();
    if (size == null) {
      throw const PickedFileException("That file couldn't be opened.");
    }

    final file = PickedFile(path: path, name: selected.name, sizeInBytes: size);
    validatePickedFile(
      file,
      allowedExtensions: _allowedExtensions,
      maxSizeInBytes: _maxSizeInBytes,
      typeMessage: 'Choose a PDF, DOC or DOCX file.',
      sizeMessage: 'Choose a file up to 5 MB.',
    );
    return file;
  }
}
