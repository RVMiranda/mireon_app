import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  GetFavoritesUseCase(this.repository);

  final FavoritesRepository repository;

  Future<Set<String>> call({String? profileId}) =>
      repository.getAll(profileId: profileId);
}
