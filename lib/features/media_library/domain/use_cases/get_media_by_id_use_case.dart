import '../entities/media_item.dart';
import '../repositories/media_library_repository.dart';

class GetMediaByIdUseCase {
  const GetMediaByIdUseCase(this._repository);

  final MediaLibraryRepository _repository;

  Future<MediaItem?> call(String mediaId) {
    return _repository.getById(mediaId);
  }
}
