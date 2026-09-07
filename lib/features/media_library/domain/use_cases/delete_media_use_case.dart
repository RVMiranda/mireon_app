import '../../../../core/platform/media/media_delete_service.dart';

class DeleteMediaUseCase {
  const DeleteMediaUseCase({required this.deleteService});
  final MediaDeleteService deleteService;
  Future<List<String>> call(List<String> mediaIds) async {
    if (mediaIds.isEmpty) return const [];
    final requested = mediaIds.toSet();
    final deleted = await deleteService.deleteByIds(requested.toList());
    return deleted.where(requested.contains).toSet().toList(growable: false);
  }
}
