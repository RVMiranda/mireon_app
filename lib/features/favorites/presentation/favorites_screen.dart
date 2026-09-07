import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../media_library/domain/entities/media_item.dart';
import '../../media_library/domain/entities/media_type.dart';
import '../../media_library/presentation/view_models/media_library_providers.dart';
import '../../media_library/presentation/view_models/media_permission_notifier.dart';
import '../../media_library/presentation/view_models/media_selection_notifier.dart';
import '../../media_library/presentation/widgets/selection_action_bar.dart';
import '../../media_viewer/presentation/models/media_viewer_args.dart';
import 'view_models/favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(mediaPermissionProvider);
    final selectionState = ref.watch(selectionNotifierProvider);
    final selectionNotifier = ref.read(selectionNotifierProvider.notifier);
    final favoritesAsync = ref.watch(favoriteMediaItemsProvider);
    final items = favoritesAsync.asData?.value ?? const <MediaItem>[];

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
              : 'Favoritos',
        ),
        actions: [
          if (items.isNotEmpty) ...[
            if (selectionState.isSelectionMode) ...[
              IconButton(
                icon: Icon(
                  selectionState.count > 0 &&
                          selectionState.count == items.length
                      ? Icons.deselect_rounded
                      : Icons.select_all_rounded,
                ),
                tooltip: selectionState.count > 0 &&
                        selectionState.count == items.length
                    ? 'Deseleccionar todo'
                    : 'Seleccionar todo',
                onPressed: () {
                  if (selectionState.count == items.length) {
                    selectionNotifier.deselectAll();
                  } else {
                    selectionNotifier.selectAll(
                      items.map((e) => e.id).toList(),
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
      body: permissionState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Info(
          title: 'No se pudo comprobar el permiso.',
          buttonLabel: 'Reintentar',
          onPressed: () =>
              ref.read(mediaPermissionProvider.notifier).refreshStatus(),
        ),
        data: (hasPermission) {
          if (!hasPermission) {
            return _Info(
              title: 'Se necesita permiso para mostrar tu galería local.',
              buttonLabel: 'Conceder acceso',
              onPressed: () async {
                await ref
                    .read(mediaPermissionProvider.notifier)
                    .requestAccess();
              },
            );
          }

          return favoritesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _Info(
              title: 'No se pudieron cargar los favoritos.',
              buttonLabel: 'Reintentar',
              onPressed: () => ref.invalidate(favoriteMediaItemsProvider),
            ),
            data: (favItems) {
              if (favItems.isEmpty) {
                return const Center(child: Text('Sin favoritos todavía.'));
              }

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(favoritesIdsProvider);
                      ref.invalidate(favoriteMediaItemsProvider);
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: favItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemBuilder: (context, index) {
                        final item = favItems[index];
                        final isSelected = selectionState.isSelected(item.id);

                        return _FavoriteTile(
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
                                  items: favItems,
                                  initialIndex: index,
                                  sourceLabel: 'Favoritos',
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
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({
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

class _Info extends StatelessWidget {
  const _Info({
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
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
