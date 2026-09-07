import 'package:flutter_test/flutter_test.dart';
import 'package:mireon/features/media_library/domain/entities/media_filter.dart';
import 'package:mireon/features/media_library/domain/entities/media_item.dart';
import 'package:mireon/features/media_library/domain/entities/media_page.dart';
import 'package:mireon/features/media_library/domain/entities/media_type.dart';
import 'package:mireon/features/media_library/domain/use_cases/fetch_media_page_use_case.dart';
import 'package:mireon/features/media_library/domain/repositories/media_library_repository.dart';
import 'package:mireon/features/media_library/presentation/view_models/media_gallery_notifier.dart';

class FakeMediaLibraryRepository implements MediaLibraryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<MediaPage> fetchMediaPage({
    required MediaFilter filter,
    required int page,
    required int pageSize,
  }) async {
    return MediaPage(
      items: [
        MediaItem(
          id: 'item-1',
          type: MediaType.image,
          width: 100,
          height: 100,
          title: 'Photo 1',
          duration: Duration.zero,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MediaItem(
          id: 'item-2',
          type: MediaType.video,
          width: 200,
          height: 200,
          title: 'Video 1',
          duration: const Duration(seconds: 10),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      totalCount: 2,
      page: page,
      pageSize: pageSize,
    );
  }
}

void main() {
  group('MediaGalleryNotifier', () {
    test(
      'removeItemsByIds removes specified items and updates totalCount',
      () async {
        final fakeRepo = FakeMediaLibraryRepository();
        final fetchPageUseCase = FetchMediaPageUseCase(fakeRepo);
        final notifier = MediaGalleryNotifier(
          filter: MediaFilter.all,
          fetchMediaPage: fetchPageUseCase,
        );

        // Wait for initial load
        await Future<void>.delayed(Duration.zero);

        expect(notifier.state.items.length, equals(2));
        expect(notifier.state.totalCount, equals(2));

        notifier.removeItemsByIds(['item-1']);

        expect(notifier.state.items.length, equals(1));
        expect(notifier.state.items.first.id, equals('item-2'));
        expect(notifier.state.totalCount, equals(1));
      },
    );
  });
}
