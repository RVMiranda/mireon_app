import 'media_item.dart';

class MediaPage {
  const MediaPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<MediaItem> items;
  final int totalCount;
  final int page;
  final int pageSize;
}
