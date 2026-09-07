import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local_file_manager_repository.dart';
import '../domain/entities/file_entry.dart';
import '../domain/repositories/file_manager_repository.dart';
final fileManagerRepositoryProvider=Provider<FileManagerRepository>((ref)=>LocalFileManagerRepository());
final fileManagerPathProvider=FutureProvider<String>((ref)=>ref.watch(fileManagerRepositoryProvider).rootPath());
final fileManagerEntriesProvider=FutureProvider.family<List<FileEntry>,String>((ref,p)=>ref.watch(fileManagerRepositoryProvider).list(p));
