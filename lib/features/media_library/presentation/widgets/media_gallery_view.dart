import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../media_viewer/presentation/models/media_viewer_args.dart';
import '../../domain/entities/media_filter.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_type.dart';
import '../../domain/entities/media_access.dart';
import '../view_models/media_gallery_notifier.dart';
import '../view_models/media_library_providers.dart';
import '../view_models/media_permission_notifier.dart';
import '../view_models/media_selection_notifier.dart';

class MediaGalleryView extends ConsumerStatefulWidget {
  const MediaGalleryView({required this.filter, super.key});

  final MediaFilter filter;

  @override
  ConsumerState<MediaGalleryView> createState() => _MediaGalleryViewState();
}

class _MediaGalleryViewState extends ConsumerState<MediaGalleryView> {
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
    final permissionState = ref.watch(mediaPermissionProvider);

    return permissionState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _PermissionInfo(
        title: 'No se pudo comprobar el permiso.',
        buttonLabel: 'Reintentar',
        onPressed: () =>
            ref.read(mediaPermissionProvider.notifier).refreshStatus(),
      ),
      data: (hasPermission) {
        if (!hasPermission) {
          return _PermissionInfo(
            title: 'Se necesita permiso para mostrar tu galería local.',
            buttonLabel: 'Conceder acceso',
            onPressed: () async {
              await ref.read(mediaPermissionProvider.notifier).requestAccess();
            },
          );
        }

        final galleryState = ref.watch(mediaGalleryProvider(widget.filter));
        final access = ref.watch(mediaAccessProvider).valueOrNull;
        final galleryNotifier = ref.read(
          mediaGalleryProvider(widget.filter).notifier,
        );
        final selectionState = ref.watch(selectionNotifierProvider);
        final selectionNotifier = ref.read(selectionNotifierProvider.notifier);

        if (galleryState.isLoading && galleryState.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (galleryState.errorMessage != null && galleryState.items.isEmpty) {
          return _PermissionInfo(
            title: galleryState.errorMessage!,
            buttonLabel: 'Reintentar',
            onPressed: galleryNotifier.refresh,
          );
        }

        if (galleryState.items.isEmpty) {
          return const Center(child: Text('No se encontraron elementos.'));
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: galleryNotifier.refresh,
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: galleryState.items.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  if (index == galleryState.items.length) {
                    if (!galleryState.hasMore) {
                      return const SizedBox.shrink();
                    }

                    return const Center(child: CircularProgressIndicator());
                  }

                  final item = galleryState.items[index];
                  final isSelected = selectionState.isSelected(item.id);

                  return _MediaTile(
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
                            items: galleryState.items,
                            initialIndex: index,
                            sourceLabel: _labelFromFilter(widget.filter),
                            totalCount: galleryState.totalCount,
                            loadPage: (page) => ref
                                .read(fetchMediaPageUseCaseProvider)(
                                  filter: widget.filter,
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
            if (access == MediaAccess.limited)
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: _LimitedAccessBanner(
                  onManage: () => ref
                      .read(mediaPermissionProvider.notifier)
                      .manageLimitedAccess(widget.filter),
                ),
              ),
          ],
        );
      },
    );
  }

  String _labelFromFilter(MediaFilter filter) {
    return switch (filter) {
      MediaFilter.all => 'Biblioteca',
      MediaFilter.photos => 'Fotos',
      MediaFilter.videos => 'Videos',
    };
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 600;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(mediaGalleryProvider(widget.filter).notifier).loadMore();
    }
  }
}

class _MediaTile extends ConsumerWidget {
  const _MediaTile({
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

class _PermissionInfo extends StatelessWidget {
  const _PermissionInfo({
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_open_rounded, size: 40),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}

class _LimitedAccessBanner extends StatelessWidget {
  const _LimitedAccessBanner({required this.onManage});
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      color: colors.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        child: Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: colors.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Acceso limitado: solo se muestran elementos seleccionados.',
              ),
            ),
            TextButton(onPressed: onManage, child: const Text('Gestionar')),
          ],
        ),
      ),
    );
  }
}
