import '../../../media_library/domain/entities/media_page.dart';
import '../repositories/albums_repository.dart';

class FetchAlbumMediaPageUseCase {
  const FetchAlbumMediaPageUseCase(this._repository);

  final AlbumsRepository _repository;

  Future<MediaPage> call({
    required String albumId,
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchAlbumMediaPage(
      albumId: albumId,
      page: page,
      pageSize: pageSize,
    );
  }
}
