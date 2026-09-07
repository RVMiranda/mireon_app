import '../repositories/favorites_repository.dart';

class SetFavoriteUseCase {
  SetFavoriteUseCase(this.repository);

  final FavoritesRepository repository;

  Future<void> call(String mediaId, bool isFavorite, {String? profileId}) {
    return repository.setFavorite(mediaId, isFavorite, profileId: profileId);
  }
}
