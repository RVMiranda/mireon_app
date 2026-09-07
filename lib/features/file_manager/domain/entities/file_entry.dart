enum FileEntryType { file, directory }
class FileEntry { const FileEntry({required this.path, required this.name, required this.type, required this.size, required this.modified}); final String path; final String name; final FileEntryType type; final int size; final DateTime modified; }
