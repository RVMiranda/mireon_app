import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'file_manager_providers.dart';
import '../domain/entities/file_entry.dart';
import 'package:file_picker/file_picker.dart';
import 'file_manager_selection.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  const FileManagerScreen({super.key});
  @override ConsumerState<FileManagerScreen> createState() => _FileManagerState();
}

class _FileManagerState extends ConsumerState<FileManagerScreen> {
  String? currentPath;
  final List<String> _pathStack = [];
  @override
  Widget build(BuildContext context) {
    return ref.watch(fileManagerPathProvider).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('No se pudo abrir Archivos: $e'))),
      data: (root) {
        final path = currentPath ?? (_pathStack.isEmpty ? root : _pathStack.last);
        final entries = ref.watch(fileManagerEntriesProvider(path));
        final selected = ref.watch(fileManagerSelectionProvider);
        return Scaffold(
          appBar: AppBar(title: Text(selected.isEmpty ? 'Archivos' : '${selected.length} seleccionados'), leading: (currentPath != null || _pathStack.isNotEmpty) ? BackButton(onPressed: () => setState(() { currentPath = null; if (_pathStack.isNotEmpty) _pathStack.removeLast(); })) : null, actions: [IconButton(onPressed: _pickExternalFolder, icon: const Icon(Icons.folder_open)), IconButton(onPressed: () => _create(path), icon: const Icon(Icons.create_new_folder_outlined))]),
          body: entries.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('$e')), data: (items) => RefreshIndicator(onRefresh: () async => ref.invalidate(fileManagerEntriesProvider(path)), child: ListView(children: items.isEmpty ? [const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Esta carpeta está vacía')))] : items.map((item) { final isSelected = selected.contains(item.path); return ListTile(selected: isSelected, leading: Icon(item.type == FileEntryType.directory ? Icons.folder : Icons.insert_drive_file_outlined), title: Text(item.name), subtitle: Text(item.type == FileEntryType.directory ? 'Carpeta' : '${item.size} bytes'), onTap: selected.isNotEmpty ? () => _toggle(item.path) : (item.type == FileEntryType.directory ? () => setState(() => currentPath = item.path) : null), onLongPress: () => _toggle(item.path), trailing: selected.isNotEmpty ? Checkbox(value: isSelected, onChanged: (_) => _toggle(item.path)) : null); }).toList()))),
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

  void _toggle(String path) {
    final notifier = ref.read(fileManagerSelectionProvider.notifier);
    final next = Set<String>.from(notifier.state);
    next.contains(path) ? next.remove(path) : next.add(path);
    notifier.state = next;
  }

  Future<void> _pickExternalFolder() async {
    final path = await FilePicker.getDirectoryPath(dialogTitle: 'Seleccionar carpeta');
    if (path == null || !mounted) return;
    setState(() { _pathStack..clear()..add(path); });
  }

  Future<void> _delete(FileEntry item, String parent) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar ${item.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))])) ?? false;
    if (!ok) return;
    try { await ref.read(fileManagerRepositoryProvider).delete(item.path); ref.invalidate(fileManagerEntriesProvider(parent)); } catch (e) { _showError(e); }
  }

  Future<void> _rename(FileEntry item, String parent) async {
    final c = TextEditingController(text: item.name);
    final name = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Renombrar'), content: TextField(controller: c), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('Guardar'))]));
    if (name == null) return;
    try { await ref.read(fileManagerRepositoryProvider).rename(item.path, name); ref.invalidate(fileManagerEntriesProvider(parent)); } catch (e) { _showError(e); }
  }

  Future<void> _showContextMenu(FileEntry item, String parent) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Renombrar'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: const Text('Eliminar'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const ListTile(
              enabled: false,
              leading: Icon(Icons.more_horiz),
              title: Text('Copiar, mover y compartir estarán disponibles con el acceso SAF.'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'rename') await _rename(item, parent);
    if (action == 'delete') await _delete(item, parent);
  }

  void _showError(Object error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error'))); }
}
