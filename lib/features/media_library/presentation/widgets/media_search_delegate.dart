import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../media_viewer/presentation/models/media_viewer_args.dart';
import '../../domain/entities/media_filter.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_type.dart';
import '../view_models/media_gallery_notifier.dart';
import '../view_models/media_library_providers.dart';

class MediaSearchDelegate extends SearchDelegate<MediaItem?> {
  MediaSearchDelegate({required this.ref})
    : super(
        searchFieldLabel: 'Buscar fotos o videos...',
        keyboardType: TextInputType.text,
      );

  final WidgetRef ref;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final galleryState = ref.watch(mediaGalleryProvider(MediaFilter.all));
    final items = galleryState.items;

    if (galleryState.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final trimmed = query.trim().toLowerCase();
    final results = trimmed.isEmpty
        ? items
        : items
              .where((item) {
                final title = item.title?.toLowerCase() ?? '';
                final typeStr = item.type.name.toLowerCase();
                return title.contains(trimmed) || typeStr.contains(trimmed);
              })
              .toList(growable: false);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              trimmed.isEmpty
                  ? 'No hay elementos en la biblioteca.'
                  : 'No se encontraron resultados para "$query"',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = results[index];
        return _SearchMediaTile(
          item: item,
          onTap: () {
            close(context, item);
            context.push(
              AppRoutes.mediaViewer,
              extra: MediaViewerArgs(
                items: results,
                initialIndex: index,
                sourceLabel: 'Búsqueda',
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchMediaTile extends ConsumerWidget {
  const _SearchMediaTile({required this.item, required this.onTap});

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
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: thumbAsync.when(
                data: (bytes) {
                  if (bytes == null || bytes.isEmpty) {
                    return const Center(child: Icon(Icons.image_not_supported));
                  }
                  return Image.memory(bytes, fit: BoxFit.cover);
                },
                error: (_, _) => const Icon(Icons.broken_image_outlined),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
            if (item.type == MediaType.video)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
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
                          fontWeight: FontWeight.w500,
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
