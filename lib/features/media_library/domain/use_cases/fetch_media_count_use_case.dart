import '../entities/media_filter.dart';
import '../repositories/media_library_repository.dart';

class FetchMediaCountUseCase {
  const FetchMediaCountUseCase(this._repository);

  final MediaLibraryRepository _repository;

  Future<int> call(MediaFilter filter) {
    return _repository.fetchMediaCount(filter);
  }
}
