import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'file_manager_providers.dart';
import '../domain/entities/file_entry.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  const FileManagerScreen({super.key});
  @override ConsumerState<FileManagerScreen> createState() => _FileManagerState();
}

class _FileManagerState extends ConsumerState<FileManagerScreen> {
  String? currentPath;
  @override
  Widget build(BuildContext context) {
    return ref.watch(fileManagerPathProvider).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('No se pudo abrir Archivos: $e'))),
      data: (root) {
        final path = currentPath ?? root;
        final entries = ref.watch(fileManagerEntriesProvider(path));
        return Scaffold(
          appBar: AppBar(title: const Text('Archivos'), leading: currentPath == null ? null : BackButton(onPressed: () => setState(() => currentPath = null)), actions: [IconButton(onPressed: () => _create(path), icon: const Icon(Icons.create_new_folder_outlined))]),
          body: entries.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (items) => RefreshIndicator(onRefresh: () async => ref.invalidate(fileManagerEntriesProvider(path)), child: ListView(children: items.isEmpty ? [const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Esta carpeta está vacía')))] : items.map((item) => ListTile(leading: Icon(item.type == FileEntryType.directory ? Icons.folder : Icons.insert_drive_file_outlined), title: Text(item.name), subtitle: Text(item.type == FileEntryType.directory ? 'Carpeta' : '${item.size} bytes'), onTap: item.type == FileEntryType.directory ? () => setState(() => currentPath = item.path) : null, onLongPress: () => _delete(item, path))).toList()))),
        );
      },
    );
  }

  Future<void> _create(String parent) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Nueva carpeta'), content: TextField(controller: controller), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Crear'))]));
    if (name == null) return;
    try { await ref.read(fileManagerRepositoryProvider).createDirectory(parent, name); ref.invalidate(fileManagerEntriesProvider(parent)); } catch (e) { _showError(e); }
  }

  Future<void> _delete(FileEntry item, String parent) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar ${item.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))])) ?? false;
    if (!ok) return;
    try { await ref.read(fileManagerRepositoryProvider).delete(item.path); ref.invalidate(fileManagerEntriesProvider(parent)); } catch (e) { _showError(e); }
  }

  void _showError(Object error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error'))); }
}
