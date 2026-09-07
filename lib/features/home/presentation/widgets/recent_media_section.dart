import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../media_library/domain/entities/media_filter.dart';
import '../../../media_library/domain/entities/media_item.dart';
import '../../../media_library/domain/entities/media_type.dart';
import '../../../media_library/presentation/view_models/media_gallery_notifier.dart';
import '../../../media_library/presentation/view_models/media_library_providers.dart';
import '../../../media_viewer/presentation/models/media_viewer_args.dart';

class RecentMediaSection extends ConsumerStatefulWidget {
  const RecentMediaSection({super.key});

  @override
  ConsumerState<RecentMediaSection> createState() => _RecentMediaSectionState();
}

class _RecentMediaSectionState extends ConsumerState<RecentMediaSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(mediaGalleryProvider(MediaFilter.all));
    final items = galleryState.items;

    if (galleryState.isLoading && items.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort items descending by createdAt to get the absolute newest first
    final sortedItems = List<MediaItem>.of(items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Limit to max 12 items for recent section
    final maxRecentItems = sortedItems.take(12).toList(growable: false);
    final collapsedItems = maxRecentItems.take(6).toList(growable: false);
    final displayItems = _isExpanded ? maxRecentItems : collapsedItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recientes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 28,
                ),
                tooltip: _isExpanded ? 'Contraer' : 'Desplegar más recientes',
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          firstChild: SizedBox(
            height: 155,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: collapsedItems.length,
              itemBuilder: (context, index) {
                final item = collapsedItems[index];
                return _RecentTile(
                  item: item,
                  onTap: () {
                    context.push(
                      AppRoutes.mediaViewer,
                      extra: MediaViewerArgs(
                        items: maxRecentItems,
                        initialIndex: index,
                        sourceLabel: 'Recientes',
                      ),
                    );
                  },
                );
              },
            ),
          ),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return _RecentGridTile(
                  item: item,
                  onTap: () {
                    context.push(
                      AppRoutes.mediaViewer,
                      extra: MediaViewerArgs(
                        items: displayItems,
                        initialIndex: index,
                        sourceLabel: 'Recientes',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentTile extends ConsumerWidget {
  const _RecentTile({required this.item, required this.onTap});

  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbAsync = ref.watch(
      mediaThumbnailProvider(
        MediaThumbnailRequest(mediaId: item.id, width: 300, height: 300),
      ),
    );

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: thumbAsync.when(
                  data: (bytes) {
                    if (bytes == null || bytes.isEmpty) {
                      return const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      );
                    }
                    return Image.memory(bytes, fit: BoxFit.cover);
                  },
                  error: (_, _) => const Icon(Icons.broken_image_outlined),
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              if (item.type == MediaType.video)
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            _fmtDuration(item.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = value.inHours;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }
}

class _RecentGridTile extends ConsumerWidget {
  const _RecentGridTile({required this.item, required this.onTap});

  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbAsync = ref.watch(
      mediaThumbnailProvider(
        MediaThumbnailRequest(mediaId: item.id, width: 300, height: 300),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: thumbAsync.when(
                data: (bytes) {
                  if (bytes == null || bytes.isEmpty) {
                    return const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    );
                  }
                  return Image.memory(bytes, fit: BoxFit.cover);
                },
                error: (_, _) => const Icon(Icons.broken_image_outlined),
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            if (item.type == MediaType.video)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _fmtDuration(item.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmtDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = value.inHours;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }
}
