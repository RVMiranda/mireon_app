import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaSelectionState {
  const MediaSelectionState({
    this.isSelectionMode = false,
    this.selectedIds = const <String>{},
  });

  final bool isSelectionMode;
  final Set<String> selectedIds;

  int get count => selectedIds.length;

  bool isSelected(String id) => selectedIds.contains(id);

  MediaSelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedIds,
  }) {
    return MediaSelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class MediaSelectionNotifier extends StateNotifier<MediaSelectionState> {
  MediaSelectionNotifier() : super(const MediaSelectionState());

  void enterSelectionMode([String? initialId]) {
    final newSet = <String>{};
    if (initialId != null) {
      newSet.add(initialId);
    }
    state = state.copyWith(isSelectionMode: true, selectedIds: newSet);
  }

  void exitSelectionMode() {
    state = const MediaSelectionState();
  }

  void toggleSelection(String id) {
    if (!state.isSelectionMode) {
      enterSelectionMode(id);
      return;
    }

    final updated = Set<String>.from(state.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    if (updated.isEmpty) {
      state = const MediaSelectionState();
    } else {
      state = state.copyWith(selectedIds: updated);
    }
  }

  void selectAll(List<String> ids) {
    state = state.copyWith(isSelectionMode: true, selectedIds: ids.toSet());
  }

  void deselectAll() {
    if (state.isSelectionMode) {
      state = state.copyWith(selectedIds: const <String>{});
    }
  }
}

final selectionNotifierProvider =
    StateNotifierProvider.autoDispose<
      MediaSelectionNotifier,
      MediaSelectionState
    >((ref) {
      return MediaSelectionNotifier();
    });
