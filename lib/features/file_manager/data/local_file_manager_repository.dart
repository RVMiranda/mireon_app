import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/file_entry.dart';
import '../domain/repositories/file_manager_repository.dart';
class LocalFileManagerRepository implements FileManagerRepository {
 Future<String> rootPath() async => (await getApplicationDocumentsDirectory()).path;
 Future<List<FileEntry>> list(String path) async { final d=Directory(path); if(!await d.exists()) return const []; final out=<FileEntry>[]; await for(final e in d.list(followLinks:false)){try{final s=await e.stat(); out.add(FileEntry(path:e.path,name:e.uri.pathSegments.last,type:s.type==FileSystemEntityType.directory?FileEntryType.directory:FileEntryType.file,size:s.type==FileSystemEntityType.file?s.size:0,modified:s.modified));}on FileSystemException{}} out.sort((a,b){final t=a.type.index.compareTo(b.type.index);return t!=0?t:a.name.toLowerCase().compareTo(b.name.toLowerCase());}); return out; }
 Future<void> createDirectory(String p,String n) async { _valid(n); await Directory('$p${Platform.pathSeparator}$n').create(); }
 Future<void> rename(String p,String n) async { _valid(n); final e=FileSystemEntity.typeSync(p)==FileSystemEntityType.directory?Directory(p):File(p); await e.rename('${e.parent.path}${Platform.pathSeparator}$n'); }
 Future<void> delete(String p) async { final t=await FileSystemEntity.type(p); if(t==FileSystemEntityType.directory) await Directory(p).delete(recursive:true); else if(t==FileSystemEntityType.file) await File(p).delete(); }
 void _valid(String n){if(n.trim().isEmpty||n.contains('/')||n.contains('\\')||n=='.'||n=='..') throw const FormatException('Nombre no válido.');}
}
