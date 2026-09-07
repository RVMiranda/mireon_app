import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/platform/providers/device_controls_providers.dart';
import '../../../favorites/presentation/view_models/favorites_providers.dart';
import '../../../albums/presentation/view_models/albums_providers.dart';
import '../../../albums/presentation/view_models/album_gallery_notifier.dart';
import '../../../profiles/presentation/view_models/profiles_providers.dart';
import '../../domain/entities/media_filter.dart';
import '../../domain/use_cases/delete_media_use_case.dart';
import 'media_gallery_notifier.dart';
import 'media_library_providers.dart';

final mediaDeletionControllerProvider = Provider<MediaDeletionController>(
  (ref) => MediaDeletionController(
    ref,
    DeleteMediaUseCase(deleteService: ref.watch(mediaDeleteServiceProvider)),
  ),
);

/// Presentation owns provider invalidation; deletion itself is a domain operation.
class MediaDeletionController {
  const MediaDeletionController(this.ref, this.deleteMedia);
  final Ref ref;
  final DeleteMediaUseCase deleteMedia;
  Future<List<String>> call(List<String> ids) async {
    final profileIds = ref
        .read(profilesNotifierProvider)
        .profiles
        .map((p) => p.id)
        .toList();
    final favorites = ref.read(favoritesRepositoryProvider);
    final deleted = await deleteMedia.call(ids);
    if (deleted.isEmpty) return deleted;
    for (final filter in MediaFilter.values) {
      ref.read(mediaGalleryProvider(filter).notifier).removeItemsByIds(deleted);
    }
    for (final profileId in <String?>[null, ...profileIds]) {
      for (final id in deleted) {
        try {
          await favorites.setFavorite(id, false, profileId: profileId);
        } catch (_) {
          /* A stale reference remains harmless and is skipped on resolution. */
        }
      }
    }
    ref.invalidate(favoritesIdsProvider);
    ref.invalidate(favoriteMediaItemsProvider);
    ref.invalidate(albumsProvider);
    ref.invalidate(albumGalleryProvider);
    ref.invalidate(mediaCountProvider);
    ref.invalidate(mediaThumbnailProvider);
    for (final id in deleted) {
      ref.invalidate(mediaFilePathProvider(id));
    }
    return deleted;
  }
}
