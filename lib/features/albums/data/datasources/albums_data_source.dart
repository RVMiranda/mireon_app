import 'package:photo_manager/photo_manager.dart';

abstract interface class AlbumsDataSource {
  Future<List<AssetPathEntity>> fetchPaths();

  Future<List<AssetEntity>> fetchAssets({
    required AssetPathEntity path,
    required int page,
    required int pageSize,
  });
}
