import 'package:open_filex/open_filex.dart';

import 'open_file_service.dart';

class OpenFilexOpenFileService implements OpenFileService {
  @override
  Future<void> open(String filePath) async {
    await OpenFilex.open(filePath);
  }
}
