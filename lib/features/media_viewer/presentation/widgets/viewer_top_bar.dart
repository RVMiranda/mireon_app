import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:mireon/features/favorites/presentation/view_models/favorites_providers.dart';

class ViewerTopBar extends ConsumerWidget {
  const ViewerTopBar({
    super.key,
    required this.sourceLabel,
    required this.indexLabel,
    required this.mediaId,
    required this.onShare,
    required this.onInfo,
    required this.onDelete,
  });

  final String sourceLabel;
  final String indexLabel;
  final String mediaId;
  final Future<void> Function() onShare;
  final Future<void> Function() onInfo;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavAsync = ref.watch(isFavoriteProvider(mediaId));
    final toggle = ref.read(toggleFavoriteProvider(mediaId));

    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sourceLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  indexLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              unawaited(onInfo());
            },
            icon: SvgPicture.asset('resources/info-square-svgrepo-com.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          ),
          IconButton(
            onPressed: () {
              unawaited(onShare());
            },
            icon: const Icon(Icons.ios_share, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              unawaited(onDelete());
            },
            icon: SvgPicture.asset('resources/trash-bin-trash-svgrepo-com.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          ),
          IconButton(
            onPressed: isFavAsync.maybeWhen(
              data: (_) => () {
                unawaited(toggle());
              },
              orElse: () => null,
            ),
            icon: isFavAsync.when(
              loading: () => const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) =>
                  const Icon(Icons.favorite_border, color: Colors.white70),
              data: (isFav) => Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.white : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
