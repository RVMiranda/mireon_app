import '../repositories/media_library_repository.dart';

class ResolveMediaFilePathUseCase {
  const ResolveMediaFilePathUseCase(this._repository);

  final MediaLibraryRepository _repository;

  Future<String?> call(String mediaId) {
    return _repository.resolveFilePath(mediaId);
  }
}
