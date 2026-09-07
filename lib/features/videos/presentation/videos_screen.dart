import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media_library/domain/entities/media_filter.dart';
import '../../media_library/presentation/view_models/media_gallery_notifier.dart';
import '../../media_library/presentation/view_models/media_selection_notifier.dart';
import '../../media_library/presentation/widgets/media_gallery_view.dart';
import '../../media_library/presentation/widgets/selection_action_bar.dart';

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionNotifierProvider);
    final selectionNotifier = ref.read(selectionNotifierProvider.notifier);
    final mediaState = ref.watch(mediaGalleryProvider(MediaFilter.videos));

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
              : 'Videos',
        ),
        actions: [
          if (selectionState.isSelectionMode) ...[
            IconButton(
              icon: Icon(
                selectionState.count > 0 &&
                        selectionState.count == mediaState.items.length
                    ? Icons.deselect_rounded
                    : Icons.select_all_rounded,
              ),
              tooltip: selectionState.count > 0 &&
                      selectionState.count == mediaState.items.length
                  ? 'Deseleccionar todo'
                  : 'Seleccionar todo',
              onPressed: () {
                if (selectionState.count == mediaState.items.length) {
                  selectionNotifier.deselectAll();
                } else {
                  selectionNotifier.selectAll(
                    mediaState.items.map((e) => e.id).toList(),
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
      ),
      body: Stack(
        children: [
          const MediaGalleryView(filter: MediaFilter.videos),
          Align(
            alignment: Alignment.bottomCenter,
            child: SelectionActionBar(
              onClearSelection: selectionNotifier.exitSelectionMode,
            ),
          ),
        ],
      ),
    );
  }
}
