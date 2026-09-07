import 'dart:io';
import '../domain/media_file_details.dart';

class LocalMediaFileInspector implements MediaFileInspector {
  const LocalMediaFileInspector();
  @override
  Future<MediaFileDetails> inspect(String? location) async {
    if (location == null || location.isEmpty) return const MediaFileDetails();
    final uri = Uri.tryParse(location);
    if (uri != null &&
        uri.hasScheme &&
        uri.scheme != 'file' &&
        !RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(location)) {
      return MediaFileDetails(location: location);
    }
    try {
      final path = uri?.scheme == 'file' ? uri!.toFilePath() : location;
      final stat = await File(path).stat();
      return MediaFileDetails(
        location: location,
        size: stat.type == FileSystemEntityType.file ? stat.size : null,
      );
    } on FileSystemException {
      return MediaFileDetails(location: location);
    }
  }
}
