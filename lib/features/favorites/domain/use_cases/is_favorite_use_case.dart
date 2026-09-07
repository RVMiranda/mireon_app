import '../repositories/favorites_repository.dart';

class IsFavoriteUseCase {
  IsFavoriteUseCase(this.repository);

  final FavoritesRepository repository;

  Future<bool> call(String mediaId, {String? profileId}) =>
      repository.isFavorite(mediaId, profileId: profileId);
}
