import '../repositories/media_library_repository.dart';

class RequestMediaPermissionUseCase {
  const RequestMediaPermissionUseCase(this._repository);

  final MediaLibraryRepository _repository;

  Future<bool> call() {
    return _repository.requestPermission();
  }
}
