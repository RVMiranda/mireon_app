import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/media_filter.dart';

abstract interface class MediaLibraryDataSource {
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<void> presentLimited(MediaFilter filter);

  Future<int> fetchCount(MediaFilter filter);

  Future<List<AssetEntity>> fetchPage({
    required MediaFilter filter,
    required int page,
    required int pageSize,
  });

  Future<AssetEntity?> getById(String id);

  Future<String?> resolveFilePath(String id);
}
