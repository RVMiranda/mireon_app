import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/media_filter.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/use_cases/fetch_media_page_use_case.dart';
import 'media_library_providers.dart';
import '../../../profiles/presentation/view_models/profiles_providers.dart';
import '../../../profiles/domain/entities/user_profile.dart';

final mediaGalleryProvider = StateNotifierProvider.autoDispose
    .family<MediaGalleryNotifier, MediaGalleryState, MediaFilter>((
      ref,
      filter,
    ) {
      ref.watch(mediaLibraryRevisionProvider);
      final profile = ref.watch(profilesNotifierProvider).activeProfile;
      return MediaGalleryNotifier(
        filter: filter,
        fetchMediaPage: ref.watch(fetchMediaPageUseCaseProvider),
        visibility: profile,
      );
    });

class MediaGalleryNotifier extends StateNotifier<MediaGalleryState> {
  MediaGalleryNotifier({required this.filter, required this.fetchMediaPage, this.visibility})
    : super(const MediaGalleryState()) {
    _loadInitial();
  }

  static const int _pageSize = 80;

  final MediaFilter filter;
  final FetchMediaPageUseCase fetchMediaPage;
  final UserProfile? visibility;

  List<MediaItem> _visible(List<MediaItem> items) => visibility == null
      ? items
      : items.where((item) => visibility!.allowsMedia(item.id)).toList(growable: false);

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    await _loadInitial();
  }

  void removeItemsByIds(List<String> ids) {
    if (ids.isEmpty || state.items.isEmpty) {
      return;
    }
    final idsSet = ids.toSet();
    final updatedItems = state.items
        .where((item) => !idsSet.contains(item.id))
        .toList();
    final removedCount = state.items.length - updatedItems.length;
    if (removedCount > 0) {
      final newTotal = (state.totalCount - removedCount).clamp(0, 999999);
      state = state.copyWith(items: updatedItems, totalCount: newTotal);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final nextPageIndex = state.currentPage + 1;
      final page = await fetchMediaPage.call(
        filter: filter,
        page: nextPageIndex,
        pageSize: _pageSize,
      );

      final merged = List<MediaItem>.of(state.items)..addAll(_visible(page.items));

      state = state.copyWith(
        items: merged,
        totalCount: page.totalCount,
        currentPage: nextPageIndex,
        hasMore: merged.length < page.totalCount,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'No se pudo cargar mas elementos.',
      );
    }
  }

  Future<void> _loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 0,
      items: const [],
      hasMore: true,
    );

    try {
      final page = await fetchMediaPage.call(
        filter: filter,
        page: 0,
        pageSize: _pageSize,
      );

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        items: _visible(page.items),
        totalCount: page.totalCount,
        currentPage: 0,
        hasMore: page.items.length < page.totalCount,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: 'No se pudo cargar la biblioteca multimedia.',
      );
    }
  }
}

class MediaGalleryState {
  const MediaGalleryState({
    this.items = const <MediaItem>[],
    this.totalCount = 0,
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoading = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<MediaItem> items;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  MediaGalleryState copyWith({
    List<MediaItem>? items,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return MediaGalleryState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}
