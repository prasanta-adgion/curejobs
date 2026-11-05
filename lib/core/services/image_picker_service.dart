import 'package:image_picker/image_picker.dart' hide PickedFile;

import 'picked_file.dart';

/// Lets the user choose a profile photo from their gallery.
class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const _allowedExtensions = {'png', 'jpg', 'jpeg', 'webp'};
  static const _maxSizeInBytes = 5 * 1024 * 1024;

  final ImagePicker _picker;

  /// Returns the chosen photo, or null if the user cancels. Throws
  /// [PickedFileException] if the file type or size is not allowed.
  Future<PickedFile?> pickPhoto() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final file = PickedFile(
      path: image.path,
      name: image.name,
      sizeInBytes: await image.length(),
    );
    validatePickedFile(
      file,
      allowedExtensions: _allowedExtensions,
      maxSizeInBytes: _maxSizeInBytes,
      typeMessage: 'Choose a PNG, JPG or WEBP photo.',
      sizeMessage: 'Choose a photo up to 5 MB.',
    );
    return file;
  }
}
