import 'package:mireon/features/media_library/presentation/view_models/media_deletion_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/providers/device_controls_providers.dart';
import '../../../favorites/presentation/view_models/favorites_providers.dart';
import '../../../profiles/presentation/view_models/profiles_providers.dart';
import '../view_models/media_library_providers.dart';
import '../view_models/media_selection_notifier.dart';

class SelectionActionBar extends ConsumerWidget {
  const SelectionActionBar({super.key, required this.onClearSelection});

  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionNotifierProvider);
    final selectedCount = selectionState.count;

    if (!selectionState.isSelectionMode) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return SafeArea(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: selectionState.isSelectionMode
            ? Offset.zero
            : const Offset(0, 1),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                icon: Icons.ios_share_rounded,
                label: 'Compartir',
                onTap: selectedCount == 0
                    ? null
                    : () => _handleShare(
                        context,
                        ref,
                        selectionState.selectedIds,
                      ),
              ),
              _ActionButton(
                icon: Icons.favorite_rounded,
                label: 'Favoritos',
                onTap: selectedCount == 0
                    ? null
                    : () => _handleFavorite(
                        context,
                        ref,
                        selectionState.selectedIds,
                      ),
              ),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Eliminar',
                color: theme.colorScheme.error,
                onTap: selectedCount == 0
                    ? null
                    : () => _handleDelete(
                        context,
                        ref,
                        selectionState.selectedIds,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final paths = <String>[];

    for (final id in ids) {
      final path = await ref.read(mediaFilePathProvider(id).future);
      if (path != null && path.isNotEmpty) {
        paths.add(path);
      }
    }

    if (paths.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudieron resolver los archivos.')),
      );
      return;
    }

    try {
      await ref.read(shareServiceProvider).shareFiles(paths);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudieron compartir los archivos.')),
      );
    }
  }

  Future<void> _handleFavorite(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final activeProfile = ref.read(profilesNotifierProvider).activeProfile;
    final setFav = ref.read(setFavoriteUseCaseProvider);

    int added = 0;
    for (final id in ids) {
      try {
        await setFav.call(id, true, profileId: activeProfile?.id);
        added++;
      } catch (_) {}
    }

    ref.invalidate(favoritesIdsProvider);
    ref.invalidate(favoriteMediaItemsProvider);
    onClearSelection();

    messenger.showSnackBar(
      SnackBar(content: Text('$added elementos añadidos a favoritos.')),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar elementos'),
        content: Text(
          '¿Eliminar ${ids.length} elementos seleccionados de tu galería? Esta acción puede no ser reversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      final deleted = await ref
          .read(mediaDeletionControllerProvider)
          .call(ids.toList());

      onClearSelection();

      if (deleted.isNotEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text('${deleted.length} elementos eliminados.')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No se pudieron eliminar los elementos.'),
          ),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudieron eliminar los elementos.')),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap == null ? Colors.grey : effectiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: onTap == null ? Colors.grey : effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
