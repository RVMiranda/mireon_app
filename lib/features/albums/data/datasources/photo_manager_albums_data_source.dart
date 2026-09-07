import 'package:photo_manager/photo_manager.dart';

import 'albums_data_source.dart';

class PhotoManagerAlbumsDataSource implements AlbumsDataSource {
  const PhotoManagerAlbumsDataSource();

  @override
  Future<List<AssetPathEntity>> fetchPaths() {
    return PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
      onlyAll: false,
    );
  }

  @override
  Future<List<AssetEntity>> fetchAssets({
    required AssetPathEntity path,
    required int page,
    required int pageSize,
  }) {
    return path.getAssetListPaged(page: page, size: pageSize);
  }
}
