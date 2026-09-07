abstract interface class MediaDeleteService {
  /// Deletes the media item from the system library.
  ///
  /// Returns the list of ids that were deleted.
  Future<List<String>> deleteByIds(List<String> mediaIds);
}
