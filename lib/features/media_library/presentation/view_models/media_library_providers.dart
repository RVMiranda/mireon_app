import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

import '../../domain/entities/media_filter.dart';

import '../../data/datasources/media_library_data_source.dart';
import '../../data/datasources/photo_manager_media_library_data_source.dart';
import '../../domain/entities/media_access.dart';
import '../../data/repositories/media_library_repository_impl.dart';
import '../../domain/repositories/media_library_repository.dart';
import '../../domain/use_cases/fetch_media_count_use_case.dart';
import '../../domain/use_cases/fetch_media_page_use_case.dart';
import '../../domain/use_cases/has_media_permission_use_case.dart';
import '../../domain/use_cases/get_media_by_id_use_case.dart';
import '../../domain/use_cases/load_media_thumbnail_use_case.dart';
import '../../domain/use_cases/resolve_media_file_path_use_case.dart';
import '../../domain/use_cases/request_media_permission_use_case.dart';
import '../../domain/use_cases/present_limited_media_access_use_case.dart';

final mediaLibraryRevisionProvider = StateProvider<int>((ref) => 0);

final mediaLibraryDataSourceProvider = Provider<MediaLibraryDataSource>((ref) {
  final source = const PhotoManagerMediaLibraryDataSource();
  PhotoManager.startChangeNotify();
  PhotoManager.addChangeCallback((_) {
    ref.read(mediaLibraryRevisionProvider.notifier).state++;
  });
  ref.onDispose(() {
    PhotoManager.stopChangeNotify();
  });
  return source;
});

final mediaAccessProvider = FutureProvider<MediaAccess>((ref) async {
  final source = ref.watch(mediaLibraryDataSourceProvider);
  if (source is PhotoManagerMediaLibraryDataSource) {
    return source.accessState();
  }
  return source.hasPermission().then(
    (allowed) => allowed ? MediaAccess.full : MediaAccess.denied,
  );
});

final mediaLibraryRepositoryProvider = Provider<MediaLibraryRepository>((ref) {
  return MediaLibraryRepositoryImpl(
    dataSource: ref.watch(mediaLibraryDataSourceProvider),
  );
});

final fetchMediaPageUseCaseProvider = Provider<FetchMediaPageUseCase>((ref) {
  return FetchMediaPageUseCase(ref.watch(mediaLibraryRepositoryProvider));
});

final fetchMediaCountUseCaseProvider = Provider<FetchMediaCountUseCase>((ref) {
  return FetchMediaCountUseCase(ref.watch(mediaLibraryRepositoryProvider));
});

final hasMediaPermissionUseCaseProvider = Provider<HasMediaPermissionUseCase>((
  ref,
) {
  return HasMediaPermissionUseCase(ref.watch(mediaLibraryRepositoryProvider));
});

final requestMediaPermissionUseCaseProvider =
    Provider<RequestMediaPermissionUseCase>((ref) {
      return RequestMediaPermissionUseCase(
        ref.watch(mediaLibraryRepositoryProvider),
      );
    });

final presentLimitedMediaAccessUseCaseProvider =
    Provider<PresentLimitedMediaAccessUseCase>(
      (ref) => PresentLimitedMediaAccessUseCase(
        ref.watch(mediaLibraryRepositoryProvider),
      ),
    );

final loadMediaThumbnailUseCaseProvider = Provider<LoadMediaThumbnailUseCase>((
  ref,
) {
  return LoadMediaThumbnailUseCase(ref.watch(mediaLibraryRepositoryProvider));
});

final resolveMediaFilePathUseCaseProvider =
    Provider<ResolveMediaFilePathUseCase>((ref) {
      return ResolveMediaFilePathUseCase(
        ref.watch(mediaLibraryRepositoryProvider),
      );
    });

final getMediaByIdUseCaseProvider = Provider<GetMediaByIdUseCase>((ref) {
  return GetMediaByIdUseCase(ref.watch(mediaLibraryRepositoryProvider));
});

final mediaThumbnailProvider = FutureProvider.autoDispose
    .family<Uint8List?, MediaThumbnailRequest>((ref, request) async {
      final useCase = ref.watch(loadMediaThumbnailUseCaseProvider);
      return useCase.call(
        request.mediaId,
        width: request.width,
        height: request.height,
      );
    });

final mediaFilePathProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, mediaId) async {
      final useCase = ref.watch(resolveMediaFilePathUseCaseProvider);
      return useCase.call(mediaId);
    });

class MediaThumbnailRequest {
  const MediaThumbnailRequest({
    required this.mediaId,
    required this.width,
    required this.height,
  });

  final String mediaId;
  final int width;
  final int height;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MediaThumbnailRequest &&
        other.mediaId == mediaId &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(mediaId, width, height);
}

final mediaCountProvider = FutureProvider.autoDispose.family<int, MediaFilter>((
  ref,
  filter,
) async {
  final useCase = ref.watch(fetchMediaCountUseCaseProvider);
  return useCase.call(filter);
});
