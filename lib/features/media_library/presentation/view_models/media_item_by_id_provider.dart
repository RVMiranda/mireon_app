import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/media_item.dart';
import 'media_library_providers.dart';

final mediaItemByIdProvider = FutureProvider.autoDispose
    .family<MediaItem?, String>((ref, mediaId) async {
      final useCase = ref.watch(getMediaByIdUseCaseProvider);
      return useCase.call(mediaId);
    });
