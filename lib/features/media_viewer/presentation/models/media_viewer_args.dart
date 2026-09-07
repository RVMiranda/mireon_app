import '../../../media_library/domain/entities/media_item.dart';

class MediaViewerArgs {
  const MediaViewerArgs({
    required this.items,
    required this.initialIndex,
    required this.sourceLabel,
    this.loadPage,
    this.totalCount,
  });

  final List<MediaItem> items;
  final int initialIndex;
  final String sourceLabel;

  /// Loads the next page for this exact originating context.
  final Future<List<MediaItem>> Function(int page)? loadPage;
  final int? totalCount;
}
