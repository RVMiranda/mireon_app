import 'dart:typed_data';

import '../entities/media_filter.dart';
import '../entities/media_item.dart';
import '../entities/media_page.dart';

abstract interface class MediaLibraryRepository {
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<void> presentLimited(MediaFilter filter);

  Future<MediaPage> fetchMediaPage({
    required MediaFilter filter,
    required int page,
    required int pageSize,
  });

  Future<int> fetchMediaCount(MediaFilter filter);

  Future<Uint8List?> loadThumbnail(
    String mediaId, {
    required int width,
    required int height,
  });

  Future<String?> resolveFilePath(String mediaId);

  Future<MediaItem?> getById(String mediaId);
}
