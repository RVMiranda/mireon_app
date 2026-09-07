import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/media_filter.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_page.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/repositories/media_library_repository.dart';
import '../datasources/media_library_data_source.dart';

class MediaLibraryRepositoryImpl implements MediaLibraryRepository {
  MediaLibraryRepositoryImpl({required this.dataSource});

  final MediaLibraryDataSource dataSource;
  final Map<String, AssetEntity> _cache = <String, AssetEntity>{};

  @override
  Future<bool> requestPermission() {
    return dataSource.requestPermission();
  }

  @override
  Future<bool> hasPermission() {
    return dataSource.hasPermission();
  }

  @override
  Future<void> presentLimited(MediaFilter filter) =>
      dataSource.presentLimited(filter);

  @override
  Future<MediaPage> fetchMediaPage({
    required MediaFilter filter,
    required int page,
    required int pageSize,
  }) async {
    final items = await dataSource.fetchPage(
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
    final totalCount = await dataSource.fetchCount(filter);

    for (final asset in items) {
      _cache[asset.id] = asset;
    }

    return MediaPage(
      items: items.map(_toDomain).toList(growable: false),
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<int> fetchMediaCount(MediaFilter filter) {
    return dataSource.fetchCount(filter);
  }

  @override
  Future<Uint8List?> loadThumbnail(
    String mediaId, {
    required int width,
    required int height,
  }) async {
    final asset = _cache[mediaId] ?? await dataSource.getById(mediaId);
    if (asset == null) {
      return null;
    }

    _cache[asset.id] = asset;

    return asset.thumbnailDataWithSize(ThumbnailSize(width, height));
  }

  @override
  Future<String?> resolveFilePath(String mediaId) async {
    final asset = _cache[mediaId];
    if (asset != null) {
      if (asset.type == AssetType.video) {
        final url = await asset.getMediaUrl();
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
      final file = await asset.file;
      if (file != null && file.path.isNotEmpty) {
        return file.path;
      }
      final originFile = await asset.originFile;
      if (originFile != null && originFile.path.isNotEmpty) {
        return originFile.path;
      }
      final url = await asset.getMediaUrl();
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }
    return dataSource.resolveFilePath(mediaId);
  }

  @override
  Future<MediaItem?> getById(String mediaId) async {
    final asset = _cache[mediaId] ?? await dataSource.getById(mediaId);
    if (asset == null) {
      return null;
    }

    _cache[asset.id] = asset;
    return _toDomain(asset);
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
