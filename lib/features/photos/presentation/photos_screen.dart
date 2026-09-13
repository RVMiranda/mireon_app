import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';

import '../../media_library/domain/entities/media_filter.dart';
import '../../media_library/presentation/view_models/media_gallery_notifier.dart';
import '../../media_library/presentation/view_models/media_selection_notifier.dart';
import '../../media_library/presentation/widgets/media_gallery_view.dart';
import '../../media_library/presentation/widgets/selection_action_bar.dart';
import '../../media_library/presentation/widgets/media_search_delegate.dart';
import '../../profiles/presentation/widgets/profile_switcher.dart';

class PhotosScreen extends ConsumerWidget {
  const PhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionNotifierProvider);
    final selectionNotifier = ref.read(selectionNotifierProvider.notifier);
    final mediaState = ref.watch(mediaGalleryProvider(MediaFilter.photos));

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
              : 'Fotos',
        ),
        actions: [
          if (!selectionState.isSelectionMode)
            const ProfileSwitcher(),
          if (!selectionState.isSelectionMode)
            IconButton(icon: const Icon(Icons.search), tooltip: 'Buscar fotos', onPressed: () => showSearch(context: context, delegate: MediaSearchDelegate(ref: ref, filter: MediaFilter.photos))),
          if (!selectionState.isSelectionMode)
            PopupMenuButton<String>(
              tooltip: 'Cambiar biblioteca',
              onSelected: (value) => context.go(value == 'videos' ? AppRoutes.videos : AppRoutes.photos),
              itemBuilder: (_) => const [PopupMenuItem(value: 'photos', child: Text('Fotos')), PopupMenuItem(value: 'videos', child: Text('Vídeos'))],
            ),
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
          Column(children: [
            _LibraryTabs(selected: 0),
            const Expanded(child: MediaGalleryView(filter: MediaFilter.photos)),
          ]),
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

class _LibraryTabs extends StatelessWidget {
  const _LibraryTabs({required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('Fotos')), ButtonSegment(value: 1, label: Text('Vídeos'))], selected: {selected}, onSelectionChanged: (v) => context.go(v.first == 0 ? AppRoutes.photos : AppRoutes.videos)));
}
