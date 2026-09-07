import 'dart:typed_data';

import '../repositories/media_library_repository.dart';

class LoadMediaThumbnailUseCase {
  const LoadMediaThumbnailUseCase(this._repository);

  final MediaLibraryRepository _repository;

  Future<Uint8List?> call(
    String mediaId, {
    required int width,
    required int height,
  }) {
    return _repository.loadThumbnail(mediaId, width: width, height: height);
  }
}
