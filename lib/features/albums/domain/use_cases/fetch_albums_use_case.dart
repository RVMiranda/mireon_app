import '../entities/album.dart';
import '../repositories/albums_repository.dart';

class FetchAlbumsUseCase {
  const FetchAlbumsUseCase(this._repository);

  final AlbumsRepository _repository;

  Future<List<Album>> call() => _repository.fetchAlbums();
}
