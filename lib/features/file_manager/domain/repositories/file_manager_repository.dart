import '../entities/file_entry.dart';
abstract interface class FileManagerRepository { Future<String> rootPath(); Future<List<FileEntry>> list(String path); Future<void> createDirectory(String parent, String name); Future<void> rename(String path, String newName); Future<void> delete(String path); }
