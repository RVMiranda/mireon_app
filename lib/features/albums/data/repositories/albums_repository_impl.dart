import 'package:photo_manager/photo_manager.dart';

import '../../../media_library/domain/entities/media_item.dart';
import '../../../media_library/domain/entities/media_page.dart';
import '../../../media_library/domain/entities/media_type.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/albums_repository.dart';
import '../datasources/albums_data_source.dart';

class AlbumsRepositoryImpl implements AlbumsRepository {
  AlbumsRepositoryImpl({required this.dataSource});

  final AlbumsDataSource dataSource;

  final Map<String, AssetPathEntity> _pathsById = <String, AssetPathEntity>{};

  @override
  Future<List<Album>> fetchAlbums() async {
    final paths = await dataSource.fetchPaths();
    _pathsById
      ..clear()
      ..addEntries(paths.map((p) => MapEntry(p.id, p)));

    final albums = <Album>[];
    for (final path in paths) {
      final count = await path.assetCountAsync;
      albums.add(
        Album(id: path.id, name: path.name, count: count, isAll: path.isAll),
      );
    }

    albums.sort((a, b) {
      if (a.isAll != b.isAll) {
        return a.isAll ? -1 : 1;
      }
      return b.count.compareTo(a.count);
    });

    return albums;
  }

  @override
  Future<MediaPage> fetchAlbumMediaPage({
    required String albumId,
    required int page,
    required int pageSize,
  }) async {
    final path =
        _pathsById[albumId] ??
        (await dataSource.fetchPaths()).firstWhere(
          (p) => p.id == albumId,
          orElse: () => throw StateError('Album no encontrado'),
        );
    _pathsById[albumId] = path;

    final totalCount = await path.assetCountAsync;
    final assets = await dataSource.fetchAssets(
      path: path,
      page: page,
      pageSize: pageSize,
    );

    return MediaPage(
      items: assets.map(_toDomain).toList(growable: false),
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }

  MediaItem _toDomain(AssetEntity entity) {
    return MediaItem(
      id: entity.id,
      type: entity.type == AssetType.video ? MediaType.video : MediaType.image,
      width: entity.width,
      height: entity.height,
      duration: Duration(seconds: entity.duration),
      title: entity.title,
      createdAt: entity.createDateTime,
      updatedAt: entity.modifiedDateTime,
    );
  }
}
