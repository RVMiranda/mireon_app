import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../media_library/domain/entities/media_item.dart';
import '../../../media_library/presentation/view_models/media_library_providers.dart';
import '../../data/datasources/favorites_data_source.dart';
import '../../data/datasources/shared_prefs_favorites_data_source.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/use_cases/get_favorites_use_case.dart';
import '../../domain/use_cases/set_favorite_use_case.dart';

import '../../../profiles/presentation/view_models/profiles_providers.dart';

final favoritesDataSourceProvider = Provider<FavoritesDataSource>((ref) {
  return SharedPrefsFavoritesDataSource();
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    dataSource: ref.watch(favoritesDataSourceProvider),
  );
});

final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  return GetFavoritesUseCase(ref.watch(favoritesRepositoryProvider));
});

final setFavoriteUseCaseProvider = Provider<SetFavoriteUseCase>((ref) {
  return SetFavoriteUseCase(ref.watch(favoritesRepositoryProvider));
});

final favoritesIdsProvider = FutureProvider<Set<String>>((ref) async {
  final activeProfile = ref.watch(profilesNotifierProvider).activeProfile;
  final profileId = activeProfile?.id;
  final useCase = ref.watch(getFavoritesUseCaseProvider);
  return useCase.call(profileId: profileId);
});

final isFavoriteProvider = Provider.family<AsyncValue<bool>, String>((
  ref,
  mediaId,
) {
  final idsAsync = ref.watch(favoritesIdsProvider);
  return idsAsync.whenData((ids) => ids.contains(mediaId));
});

final toggleFavoriteProvider = Provider.family<Future<void> Function(), String>(
  (ref, mediaId) {
    return () async {
      final activeProfile = ref.read(profilesNotifierProvider).activeProfile;
      final profileId = activeProfile?.id;
      final ids = await ref.read(favoritesIdsProvider.future);
      final isFav = ids.contains(mediaId);
      final useCase = ref.read(setFavoriteUseCaseProvider);
      await useCase.call(mediaId, !isFav, profileId: profileId);
      ref.invalidate(favoritesIdsProvider);
    };
  },
);

final favoriteMediaItemsProvider = FutureProvider<List<MediaItem>>((ref) async {
  final ids = await ref.watch(favoritesIdsProvider.future);
  if (ids.isEmpty) {
    return const <MediaItem>[];
  }

  final getById = ref.watch(getMediaByIdUseCaseProvider);
  final results = await Future.wait(ids.map(getById.call));
  final items = results.whereType<MediaItem>().toList(growable: false);
  final resolvedIds = items.map((item) => item.id).toSet();
  final profileId = ref.read(profilesNotifierProvider).activeProfile?.id;
  await ref.read(favoritesRepositoryProvider).reconcile(
    resolvedIds,
    profileId: profileId,
  );

  final sorted = List<MediaItem>.of(items)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted;
});
