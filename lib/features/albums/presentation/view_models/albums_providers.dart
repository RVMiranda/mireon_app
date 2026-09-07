import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/albums_data_source.dart';
import '../../data/datasources/photo_manager_albums_data_source.dart';
import '../../data/repositories/albums_repository_impl.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/albums_repository.dart';
import '../../domain/use_cases/fetch_album_media_page_use_case.dart';
import '../../domain/use_cases/fetch_albums_use_case.dart';

final albumsDataSourceProvider = Provider<AlbumsDataSource>((ref) {
  return const PhotoManagerAlbumsDataSource();
});

final albumsRepositoryProvider = Provider<AlbumsRepository>((ref) {
  return AlbumsRepositoryImpl(dataSource: ref.watch(albumsDataSourceProvider));
});

final fetchAlbumsUseCaseProvider = Provider<FetchAlbumsUseCase>((ref) {
  return FetchAlbumsUseCase(ref.watch(albumsRepositoryProvider));
});

final fetchAlbumMediaPageUseCaseProvider = Provider<FetchAlbumMediaPageUseCase>(
  (ref) {
    return FetchAlbumMediaPageUseCase(ref.watch(albumsRepositoryProvider));
  },
);

final albumsProvider = FutureProvider.autoDispose<List<Album>>((ref) async {
  final useCase = ref.watch(fetchAlbumsUseCaseProvider);
  return useCase.call();
});
