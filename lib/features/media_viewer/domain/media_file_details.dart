class MediaFileDetails {
  const MediaFileDetails({this.location, this.size});
  final String? location;
  final int? size;
}

abstract interface class MediaFileInspector {
  Future<MediaFileDetails> inspect(String? location);
}
