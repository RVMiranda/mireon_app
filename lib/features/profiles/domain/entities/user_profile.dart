class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.createdAt,
    this.isProtected = false,
    this.allowedMediaIds = const <String>{},
    this.allowedAlbumIds = const <String>{},
    this.hideFromGeneralLibrary = false,
  });
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final DateTime createdAt;
  final bool isProtected;
  final Set<String> allowedMediaIds;
  final Set<String> allowedAlbumIds;
  final bool hideFromGeneralLibrary;

  bool allowsMedia(String mediaId) =>
      allowedMediaIds.isEmpty || allowedMediaIds.contains(mediaId);
}
