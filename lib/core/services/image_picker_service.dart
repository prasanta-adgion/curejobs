import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;

import 'picked_file.dart';

/// Lets the user take a profile photo or choose one from their gallery.
class ImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const _allowedExtensions = {'png', 'jpg', 'jpeg', 'webp'};
  static const _maxSizeInBytes = 25 * 1024 * 1024;

  final ImagePicker _picker;

  /// Returns the photo, or null if the user cancels. Throws
  /// [PickedFileException] if access is denied or the file type or size is
  /// not allowed. The limit is high because the photo is cropped afterwards.
  Future<PickedFile?> pickPhoto(ImageSource source) async {
    final XFile? image;
    try {
      image = await _picker.pickImage(source: source);
    } on PlatformException catch (error) {
      throw PickedFileException(switch (error.code) {
        'camera_access_denied' => 'Allow camera access in your phone settings.',
        'photo_access_denied' => 'Allow photo access in your phone settings.',
        _ => "That photo couldn't be opened.",
      });
    }
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
      sizeMessage: 'Choose a photo up to 25 MB.',
    );
    return file;
  }
}
