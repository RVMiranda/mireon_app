import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/media_filter.dart';
import '../../domain/entities/media_access.dart';
import 'media_library_data_source.dart';

class PhotoManagerMediaLibraryDataSource implements MediaLibraryDataSource {
  const PhotoManagerMediaLibraryDataSource();

  @override
  Future<void> presentLimited(MediaFilter filter) =>
      PhotoManager.presentLimited(
        type: filter == MediaFilter.videos
            ? RequestType.video
            : filter == MediaFilter.photos
            ? RequestType.image
            : RequestType.common,
      );

  Future<MediaAccess> accessState() async {
    final state = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    if (state.isAuth) return MediaAccess.full;
    if (state.hasAccess || state.isLimited) return MediaAccess.limited;
    return MediaAccess.denied;
  }

  @override
  Future<bool> requestPermission() async {
    final state = await PhotoManager.requestPermissionExtend();
    return state.hasAccess;
  }

  @override
  Future<bool> hasPermission() async {
    final state = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    return state.hasAccess;
  }

  @override
  Future<int> fetchCount(MediaFilter filter) async {
    final path = await _resolveUnifiedPath(filter);
    if (path == null) {
      return 0;
    }

    return path.assetCountAsync;
  }

  @override
  Future<List<AssetEntity>> fetchPage({
    required MediaFilter filter,
    required int page,
    required int pageSize,
  }) async {
    final path = await _resolveUnifiedPath(filter);
    if (path == null) {
      return const [];
    }

    return path.getAssetListPaged(page: page, size: pageSize);
  }

  @override
  Future<AssetEntity?> getById(String id) {
    return AssetEntity.fromId(id);
  }

  @override
  Future<String?> resolveFilePath(String id) async {
    final asset = await getById(id);
    if (asset == null) {
      return null;
    }

    if (asset.type == AssetType.video) {
      final mediaUrl = await asset.getMediaUrl();
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        return mediaUrl;
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

    final mediaUrl = await asset.getMediaUrl();
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      return mediaUrl;
    }

    return null;
  }

  Future<AssetPathEntity?> _resolveUnifiedPath(MediaFilter filter) async {
    final paths = await PhotoManager.getAssetPathList(
      type: _toRequestType(filter),
      hasAll: true,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (paths.isEmpty) {
      return null;
    }

    return paths.first;
  }

  RequestType _toRequestType(MediaFilter filter) {
    return switch (filter) {
      MediaFilter.all => RequestType.common,
      MediaFilter.photos => RequestType.image,
      MediaFilter.videos => RequestType.video,
    };
  }
}
