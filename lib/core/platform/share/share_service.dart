abstract interface class ShareService {
  Future<void> shareFile(String filePath);
  Future<void> shareFiles(List<String> filePaths);
}

