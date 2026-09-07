import 'package:share_plus/share_plus.dart';

import 'share_service.dart';

class SharePlusShareService implements ShareService {
  @override
  Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  @override
  Future<void> shareFiles(List<String> filePaths) async {
    if (filePaths.isEmpty) {
      return;
    }
    await Share.shareXFiles(filePaths.map((p) => XFile(p)).toList());
  }
}

