import 'media_type.dart';

class MediaItem {
  const MediaItem({
    required this.id,
    required this.type,
    required this.width,
    required this.height,
    required this.duration,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final MediaType type;
  final int width;
  final int height;
  final Duration duration;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
}
