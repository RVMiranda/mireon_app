import 'view_models/media_actions_controller.dart';
import 'widgets/media_info_sheet.dart';
import 'package:mireon/features/media_library/presentation/view_models/media_deletion_controller.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mireon/features/media_library/domain/entities/media_item.dart';
import 'package:mireon/features/media_library/domain/entities/media_type.dart';
import 'package:mireon/core/platform/providers/device_controls_providers.dart';
import 'package:mireon/core/platform/system_ui/system_ui_service.dart';
import 'package:mireon/features/media_viewer/presentation/models/media_viewer_args.dart';
import 'package:mireon/features/media_viewer/presentation/view_models/media_viewer_controller.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/mode_feedback_overlay.dart';

import 'package:mireon/features/media_viewer/presentation/widgets/viewer_top_bar.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/image_viewer_pane.dart';
import 'package:mireon/features/media_viewer/presentation/widgets/video_viewer_pane.dart';

class MediaViewerScreen extends ConsumerStatefulWidget {
  const MediaViewerScreen({required this.args, super.key});

  final MediaViewerArgs args;

  @override
  ConsumerState<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends ConsumerState<MediaViewerScreen> {
  late final PageController _pageController = PageController(
    initialPage: widget.args.initialIndex,
  );

  late final MediaViewerController _viewerController = MediaViewerController(
    initialIndex: widget.args.initialIndex,
  );

  late final List<MediaItem> _items = List<MediaItem>.of(widget.args.items);
  bool _loadingMore = false;
  bool get _hasMore =>
      widget.args.loadPage != null &&
      (widget.args.totalCount == null ||
          _items.length < widget.args.totalCount!);

  bool? _appliedFullscreen;
  AppOrientationLock? _appliedOrientationLock;
  late final _systemUi = ref.read(systemUiServiceProvider);

  Timer? _modeOverlayTimer;
  IconData? _modeOverlayIcon;
  String? _modeOverlayText;

  @override
  void initState() {
    super.initState();
    _viewerController.addListener(_onViewerStateChanged);
    _onViewerStateChanged();
  }

  void _onViewerStateChanged() {
    final s = _viewerController.value;
    final systemUi = _systemUi;

    if (_appliedFullscreen != s.isFullscreen) {
      _appliedFullscreen = s.isFullscreen;
      unawaited(systemUi.setFullscreen(s.isFullscreen));
    }

    if (_appliedOrientationLock != s.orientationLock) {
      _appliedOrientationLock = s.orientationLock;
      unawaited(systemUi.setOrientationLock(s.orientationLock));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _viewerController.removeListener(_onViewerStateChanged);
    unawaited(_systemUi.reset());
    _modeOverlayTimer?.cancel();
    _viewerController.dispose();
    super.dispose();
  }

  void _showModeOverlay({required IconData icon, required String text}) {
    _modeOverlayTimer?.cancel();
    setState(() {
      _modeOverlayIcon = icon;
      _modeOverlayText = text;
    });

    _modeOverlayTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _modeOverlayIcon = null;
        _modeOverlayText = null;
      });
    });
  }

  void _handleToggleFullscreen() {
    _viewerController.toggleFullscreen();
    final enabled = _viewerController.value.isFullscreen;
    _showModeOverlay(
      icon: enabled ? Icons.fullscreen : Icons.fullscreen_exit,
      text: enabled ? 'Pantalla completa' : 'Modo normal',
    );
  }

  void _handleCycleOrientationLock() {
    _viewerController.cycleOrientationLock();
    final lock = _viewerController.value.orientationLock;

    final (icon, text) = switch (lock) {
      AppOrientationLock.system => (Icons.screen_rotation, 'Orientación: Auto'),
      AppOrientationLock.landscape => (
        Icons.stay_current_landscape,
        'Orientación: Landscape',
      ),
      AppOrientationLock.portrait => (
        Icons.stay_current_portrait,
        'Orientación: Portrait',
      ),
    };

    _showModeOverlay(icon: icon, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: _viewerController,
        builder: (context, viewerState, _) {
          final current = items[viewerState.currentIndex];

          return SafeArea(
            top: !viewerState.isFullscreen,
            bottom: !viewerState.isFullscreen,
            left: !viewerState.isFullscreen,
            right: !viewerState.isFullscreen,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (index) {
                    _viewerController.setCurrentIndex(index);
                    if (index >= _items.length - 2) {
                      unawaited(_loadNextPage());
                    }
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isActive = index == viewerState.currentIndex;

                    if (item.type == MediaType.video) {
                      return VideoViewerPane(
                        key: ValueKey(item.id),
                        item: item,
                        isActive: isActive,
                        controlsVisible: viewerState.controlsVisible,
                        isFullscreen: viewerState.isFullscreen,
                        orientationLock: viewerState.orientationLock,
                        onToggleControls: _viewerController.toggleControls,
                        onToggleFullscreen: _handleToggleFullscreen,
                        onCycleOrientationLock: _handleCycleOrientationLock,
                      );
                    }

                    return ImageViewerPane(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: _viewerController.toggleControls,
                    );
                  },
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: viewerState.controlsVisible ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !viewerState.controlsVisible,
                    child: ViewerTopBar(
                      sourceLabel: widget.args.sourceLabel,
                      indexLabel:
                          '${viewerState.currentIndex + 1} / ${widget.args.totalCount ?? items.length}',
                      mediaId: current.id,
                      onShare: _shareCurrent,
                      onInfo: _showInfoForCurrent,
                      onDelete: _deleteCurrent,
                    ),
                  ),
                ),
                if (_modeOverlayIcon != null && _modeOverlayText != null)
                  ModeFeedbackOverlay(
                    icon: _modeOverlayIcon!,
                    text: _modeOverlayText!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore || !mounted) return;
    final loader = widget.args.loadPage;
    if (loader == null) return;
    _loadingMore = true;
    try {
      final next = await loader((_items.length / 80).floor());
      if (!mounted || next.isEmpty) return;
      final known = _items.map((item) => item.id).toSet();
      setState(() {
        _items.addAll(next.where((item) => known.add(item.id)));
      });
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo completar la operación.')),
        );
      }
    }
  }

  Future<void> _shareCurrent() => _runAction(() async {
    final item = _items[_viewerController.value.currentIndex];
    await ref.read(mediaActionsControllerProvider).share(item.id);
  });

  Future<void> _showInfoForCurrent() => _runAction(() async {
    final item = _items[_viewerController.value.currentIndex];
    final actions = ref.read(mediaActionsControllerProvider);
    final details = await actions.details(item.id);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => MediaInfoSheet(
        item: item,
        details: details,
        onOpen: () {
          Navigator.of(sheetContext).pop();
          unawaited(_runAction(() => actions.open(item.id)));
        },
        onShare: () {
          Navigator.of(sheetContext).pop();
          unawaited(_runAction(() => actions.share(item.id)));
        },
      ),
    );
  });

  Future<void> _deleteCurrent() async {
    final index = _viewerController.value.currentIndex;
    if (index < 0 || index >= _items.length) {
      return;
    }
    final item = _items[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: const Text(
            '¿Eliminar este elemento de tu galería? Esta acción puede no ser reversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final deleted = await ref.read(mediaDeletionControllerProvider).call([
        item.id,
      ]);
      if (!mounted) {
        return;
      }

      if (!deleted.contains(item.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el elemento.')),
        );
        return;
      }

      setState(() {
        _items.removeAt(index);
      });

      if (_items.isEmpty) {
        if (mounted) {
          Navigator.of(context).maybePop();
        }
        return;
      }

      final nextIndex = index.clamp(0, _items.length - 1);
      _viewerController.setCurrentIndex(nextIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) {
          return;
        }
        _pageController.jumpToPage(nextIndex);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Elemento eliminado.')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el elemento.')),
      );
    }
  }
}
