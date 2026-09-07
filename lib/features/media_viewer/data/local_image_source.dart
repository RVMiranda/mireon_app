import 'dart:io';
import 'package:flutter/painting.dart';

/// Rendering adapter; the widget does not open files or interpret file URIs.
class LocalImageSource {
  const LocalImageSource();
  ImageProvider? resolve(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null &&
        uri.hasScheme &&
        uri.scheme != 'file' &&
        !RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path)) {
      return null;
    }
    return FileImage(File(uri?.scheme == 'file' ? uri!.toFilePath() : path));
  }
}
