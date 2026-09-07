import '../../../media_library/domain/entities/media_page.dart';
import '../entities/album.dart';

abstract interface class AlbumsRepository {
  Future<List<Album>> fetchAlbums();

  Future<MediaPage> fetchAlbumMediaPage({
    required String albumId,
    required int page,
    required int pageSize,
  });
}
