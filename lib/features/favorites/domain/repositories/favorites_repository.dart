abstract interface class FavoritesRepository {
  Future<Set<String>> getAll({String? profileId});

  Future<bool> isFavorite(String mediaId, {String? profileId});

  Future<void> setFavorite(String mediaId, bool isFavorite, {String? profileId});

  Future<void> reconcile(Set<String> availableIds, {String? profileId});
}
