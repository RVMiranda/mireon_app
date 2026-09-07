import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../media_library/domain/entities/media_item.dart';
import '../../media_library/domain/entities/media_type.dart';
import '../../media_library/presentation/view_models/media_library_providers.dart';
import '../../media_library/presentation/view_models/media_selection_notifier.dart';
import '../../media_library/presentation/widgets/selection_action_bar.dart';
import '../../media_viewer/presentation/models/media_viewer_args.dart';
import 'view_models/album_gallery_notifier.dart';
import 'view_models/albums_providers.dart';

class AlbumMediaScreen extends ConsumerStatefulWidget {
  const AlbumMediaScreen({
    required this.albumId,
    required this.albumName,
    super.key,
  });

  final String albumId;
  final String albumName;

  @override
  ConsumerState<AlbumMediaScreen> createState() => _AlbumMediaScreenState();
}

class _AlbumMediaScreenState extends ConsumerState<AlbumMediaScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(albumGalleryProvider(widget.albumId));
    final notifier = ref.read(albumGalleryProvider(widget.albumId).notifier);
    final selectionState = ref.watch(selectionNotifierProvider);
    final selectionNotifier = ref.read(selectionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: selectionState.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: selectionNotifier.exitSelectionMode,
                tooltip: 'Cancelar selección',
              )
            : null,
        title: Text(
          selectionState.isSelectionMode
              ? '${selectionState.count} seleccionados'
              : widget.albumName,
        ),
        actions: [
          if (state.items.isNotEmpty) ...[
            if (selectionState.isSelectionMode) ...[
              IconButton(
                icon: Icon(
                  selectionState.count > 0 &&
                          selectionState.count == state.items.length
                      ? Icons.deselect_rounded
                      : Icons.select_all_rounded,
                ),
                tooltip:
                    selectionState.count > 0 &&
                        selectionState.count == state.items.length
                    ? 'Deseleccionar todo'
                    : 'Seleccionar todo',
                onPressed: () {
                  if (selectionState.count == state.items.length) {
                    selectionNotifier.deselectAll();
                  } else {
                    selectionNotifier.selectAll(
                      state.items.map((e) => e.id).toList(),
                    );
                  }
                },
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  selectionNotifier.enterSelectionMode();
                },
                child: const Text(
                  'Seleccionar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: notifier.refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.items.isEmpty) {
            return const Center(child: Text('No se encontraron elementos.'));
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: notifier.refresh,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: state.items.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      if (!state.hasMore) {
                        return const SizedBox.shrink();
                      }
                      return const Center(child: CircularProgressIndicator());
                    }

                    final item = state.items[index];
                    final isSelected = selectionState.isSelected(item.id);

                    return _AlbumMediaTile(
                      item: item,
                      isSelectionMode: selectionState.isSelectionMode,
                      isSelected: isSelected,
                      onTap: () {
                        if (selectionState.isSelectionMode) {
                          selectionNotifier.toggleSelection(item.id);
                        } else {
                          context.push(
                            AppRoutes.mediaViewer,
                            extra: MediaViewerArgs(
                              items: state.items,
                              initialIndex: index,
                              sourceLabel: widget.albumName,
                              totalCount: state.totalCount,
                              loadPage: (page) => ref
                                  .read(fetchAlbumMediaPageUseCaseProvider)(
                                    albumId: widget.albumId,
                                    page: page,
                                    pageSize: 80,
                                  )
                                  .then((result) => result.items),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        selectionNotifier.toggleSelection(item.id);
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SelectionActionBar(
                  onClearSelection: selectionNotifier.exitSelectionMode,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 600;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(albumGalleryProvider(widget.albumId).notifier).loadMore();
    }
  }
}

class _AlbumMediaTile extends ConsumerWidget {
  const _AlbumMediaTile({
    required this.item,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final MediaItem item;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbAsync = ref.watch(
      mediaThumbnailProvider(
        MediaThumbnailRequest(mediaId: item.id, width: 400, height: 400),
      ),
    );
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: thumbAsync.when(
                data: (bytes) => _ThumbImage(bytes: bytes),
                error: (_, _) => const Icon(Icons.broken_image_outlined),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
            if (item.type == MediaType.video)
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(item.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (isSelectionMode)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.25)
                      : Colors.transparent,
                ),
              ),
            if (isSelectionMode)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.black.withValues(alpha: 0.4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = value.inHours;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }
}

class _ThumbImage extends StatelessWidget {
  const _ThumbImage({required this.bytes});

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    if (bytes == null || bytes!.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported_outlined));
    }

    return Image.memory(bytes!, fit: BoxFit.cover);
  }
}
