import 'package:photo_manager/photo_manager.dart';

import 'media_delete_service.dart';

class PhotoManagerMediaDeleteService implements MediaDeleteService {
  @override
  Future<List<String>> deleteByIds(List<String> mediaIds) {
    return PhotoManager.editor.deleteWithIds(mediaIds);
  }
}
