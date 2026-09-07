import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/features/favorites/data/datasources/shared_prefs_favorites_data_source.dart';
import 'package:mireon/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Favorites are isolated between different local profiles', () async {
    final dataSource = SharedPrefsFavoritesDataSource();
    final repository = FavoritesRepositoryImpl(dataSource: dataSource);

    const profileA = 'profile_jony_1';
    const profileB = 'profile_jony_2';
    const mediaItem1 = 'photo_101';
    const mediaItem2 = 'photo_102';

    // 1. Profile A adds photo_101 to favorites
    await repository.setFavorite(mediaItem1, true, profileId: profileA);

    // 2. Profile A should have photo_101 in favorites
    final favsA = await repository.getAll(profileId: profileA);
    expect(favsA, contains(mediaItem1));

    // 3. Profile B should be completely empty
    final favsBInitial = await repository.getAll(profileId: profileB);
    expect(favsBInitial, isEmpty);

    // 4. Profile B adds photo_102 to favorites
    await repository.setFavorite(mediaItem2, true, profileId: profileB);

    // 5. Verify Profile B has photo_102, but NOT photo_101
    final favsBUpdated = await repository.getAll(profileId: profileB);
    expect(favsBUpdated, contains(mediaItem2));
    expect(favsBUpdated, isNot(contains(mediaItem1)));

    // 6. Verify Profile A still only has photo_101
    final favsAFinal = await repository.getAll(profileId: profileA);
    expect(favsAFinal, contains(mediaItem1));
    expect(favsAFinal, isNot(contains(mediaItem2)));
  });
}
