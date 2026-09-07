import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/use_cases/has_media_permission_use_case.dart';
import '../../domain/use_cases/request_media_permission_use_case.dart';
import 'media_library_providers.dart';
import '../../domain/entities/media_filter.dart';

final mediaPermissionProvider =
    AsyncNotifierProvider<MediaPermissionNotifier, bool>(
      MediaPermissionNotifier.new,
    );

class MediaPermissionNotifier extends AsyncNotifier<bool> {
  late final HasMediaPermissionUseCase _hasPermission = ref.read(
    hasMediaPermissionUseCaseProvider,
  );
  late final RequestMediaPermissionUseCase _requestPermission = ref.read(
    requestMediaPermissionUseCaseProvider,
  );

  @override
  Future<bool> build() {
    return _hasPermission.call();
  }

  Future<void> requestAccess() async {
    state = const AsyncLoading<bool>();
    state = await AsyncValue.guard(_requestPermission.call);
  }

  Future<void> refreshStatus() async {
    state = const AsyncLoading<bool>();
    state = await AsyncValue.guard(_hasPermission.call);
  }

  Future<void> manageLimitedAccess(MediaFilter filter) async {
    state = const AsyncLoading<bool>();
    final useCase = ref.read(presentLimitedMediaAccessUseCaseProvider);
    await AsyncValue.guard(() => useCase(filter));
    ref.invalidate(mediaAccessProvider);
    state = await AsyncValue.guard(_hasPermission.call);
    ref.read(mediaLibraryRevisionProvider.notifier).state++;
  }
}
