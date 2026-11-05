/// A file chosen by the user from the device.
class PickedFile {
  const PickedFile({
    required this.path,
    required this.name,
    required this.sizeInBytes,
  });

  final String path;
  final String name;
  final int sizeInBytes;
}

/// The chosen file can't be used. [message] is safe to show to the user.
class PickedFileException implements Exception {
  const PickedFileException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Checks [file] and throws [PickedFileException] if its type or size is not
/// allowed. Extensions in [allowedExtensions] must be lower case.
void validatePickedFile(
  PickedFile file, {
  required Set<String> allowedExtensions,
  required int maxSizeInBytes,
  required String typeMessage,
  required String sizeMessage,
}) {
  final name = file.name.toLowerCase();
  final extension = name.contains('.') ? name.split('.').last : '';

  if (!allowedExtensions.contains(extension)) {
    throw PickedFileException(typeMessage);
  }
  if (file.sizeInBytes > maxSizeInBytes) {
    throw PickedFileException(sizeMessage);
  }
}
