abstract interface class FavoritesDataSource {
  Future<Set<String>> load({String? profileId});

  Future<void> save(Set<String> ids, {String? profileId});
}
