import '../view_models/media_actions_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mireon/features/media_library/domain/entities/media_item.dart';
import 'package:mireon/features/media_library/presentation/view_models/media_library_providers.dart';

class ImageViewerPane extends ConsumerWidget {
  const ImageViewerPane({required this.item, required this.onTap, super.key});

  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filePathAsync = ref.watch(mediaFilePathProvider(item.id));
    final thumbAsync = ref.watch(
      mediaThumbnailProvider(
        MediaThumbnailRequest(mediaId: item.id, width: 600, height: 600),
      ),
    );

    Widget buildThumbnailWidget() {
      return thumbAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
        error: (_, _) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white70,
            size: 48,
          ),
        ),
        data: (bytes) {
          if (bytes == null || bytes.isEmpty) {
            return const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white70,
                size: 48,
              ),
            );
          }
          return Image.memory(bytes, fit: BoxFit.contain);
        },
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: filePathAsync.when(
            loading: () => buildThumbnailWidget(),
            error: (_, _) => buildThumbnailWidget(),
            data: (path) {
              if (path == null || path.isEmpty) {
                return buildThumbnailWidget();
              }

              final imageProvider = ref.watch(localMediaImageProvider(path));
              if (imageProvider == null) {
                final fullThumbAsync = ref.watch(
                  mediaThumbnailProvider(
                    MediaThumbnailRequest(
                      mediaId: item.id,
                      width: 2048,
                      height: 2048,
                    ),
                  ),
                );

                return fullThumbAsync.when(
                  loading: () => buildThumbnailWidget(),
                  error: (_, _) => buildThumbnailWidget(),
                  data: (bytes) {
                    if (bytes == null || bytes.isEmpty) {
                      return buildThumbnailWidget();
                    }
                    return Image.memory(bytes, fit: BoxFit.contain);
                  },
                );
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  buildThumbnailWidget(),
                  Image(
                    image: imageProvider,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        buildThumbnailWidget(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
