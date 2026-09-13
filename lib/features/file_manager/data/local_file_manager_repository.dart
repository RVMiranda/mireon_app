import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../domain/entities/file_entry.dart';
import '../domain/repositories/file_manager_repository.dart';

class LocalFileManagerRepository implements FileManagerRepository {
  @override Future<String> rootPath() async => (await getApplicationDocumentsDirectory()).path;
  @override Future<List<FileEntry>> list(String path) async { final d=Directory(path); if(!await d.exists()) return const []; final out=<FileEntry>[]; await for(final e in d.list(followLinks:false)){try{final s=await e.stat(); out.add(FileEntry(path:e.path,name:e.uri.pathSegments.last,type:s.type==FileSystemEntityType.directory?FileEntryType.directory:FileEntryType.file,size:s.type==FileSystemEntityType.file?s.size:0,modified:s.modified));}catch(_){}} out.sort((a,b)=>a.name.toLowerCase().compareTo(b.name.toLowerCase())); return out; }
  @override Future<void> createDirectory(String p,String n) async { _valid(n); await Directory('$p${Platform.pathSeparator}$n').create(); }
  @override Future<void> rename(String p,String n) async { _valid(n); final e=FileSystemEntity.typeSync(p)==FileSystemEntityType.directory?Directory(p):File(p); await e.rename('${e.parent.path}${Platform.pathSeparator}$n'); }
  @override Future<void> delete(String p) async { final t=await FileSystemEntity.type(p); if(t==FileSystemEntityType.directory){await Directory(p).delete(recursive:true);}else if(t==FileSystemEntityType.file){await File(p).delete();} }
  @override Future<void> copy(String s,String d) async { final n=s.split(Platform.pathSeparator).last; await File(s).copy('$d${Platform.pathSeparator}$n'); }
  @override Future<void> move(String s,String d) async { final n=s.split(Platform.pathSeparator).last; await File(s).rename('$d${Platform.pathSeparator}$n'); }
  @override Future<String> zip(List<String> sources,String destination) async { final out='$destination${Platform.pathSeparator}mireon_${DateTime.now().millisecondsSinceEpoch}.zip'; final z=ZipFileEncoder()..create(out); for(final s in sources){if(await FileSystemEntity.type(s)==FileSystemEntityType.file) z.addFile(File(s));} z.close(); return out; }
  void _valid(String n){if(n.trim().isEmpty||n.contains('/')||n.contains('\\')||n=='.'||n=='..') throw const FormatException('Nombre no válido.');}
}
