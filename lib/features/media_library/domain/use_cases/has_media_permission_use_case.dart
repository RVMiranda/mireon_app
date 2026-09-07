import '../repositories/media_library_repository.dart';

class HasMediaPermissionUseCase {
  const HasMediaPermissionUseCase(this._repository);

  final MediaLibraryRepository _repository;

  Future<bool> call() {
    return _repository.hasPermission();
  }
}
