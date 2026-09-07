import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({required this.dataSource});

  final FavoritesDataSource dataSource;

  final Map<String, Set<String>> _cacheByProfile = {};

  String _cacheKey(String? profileId) => profileId ?? 'default';

  @override
  Future<Set<String>> getAll({String? profileId}) async {
    final key = _cacheKey(profileId);
    if (!_cacheByProfile.containsKey(key)) {
      final loaded = await dataSource.load(profileId: profileId);
      _cacheByProfile[key] = loaded;
    }
    return Set<String>.from(_cacheByProfile[key]!);
  }

  @override
  Future<bool> isFavorite(String mediaId, {String? profileId}) async {
    final all = await getAll(profileId: profileId);
    return all.contains(mediaId);
  }

  @override
  Future<void> setFavorite(
    String mediaId,
    bool isFavorite, {
    String? profileId,
  }) async {
    final key = _cacheKey(profileId);
    final all = await getAll(profileId: profileId);

    if (isFavorite) {
      all.add(mediaId);
    } else {
      all.remove(mediaId);
    }

    _cacheByProfile[key] = all;
    await dataSource.save(all, profileId: profileId);
  }

  @override
  Future<void> reconcile(Set<String> availableIds, {String? profileId}) async {
    final key = _cacheKey(profileId);
    final all = await getAll(profileId: profileId);
    final stale = all.difference(availableIds);
    if (stale.isEmpty) return;
    all.removeAll(stale);
    _cacheByProfile[key] = all;
    await dataSource.save(all, profileId: profileId);
  }
}
