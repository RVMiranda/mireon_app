import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../media_library/presentation/view_models/media_permission_notifier.dart';
import 'album_media_screen.dart';
import 'view_models/albums_providers.dart';

class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(mediaPermissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Álbumes')),
      body: permissionState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Info(
          title: 'No se pudo comprobar el permiso.',
          buttonLabel: 'Reintentar',
          onPressed: () =>
              ref.read(mediaPermissionProvider.notifier).refreshStatus(),
        ),
        data: (hasPermission) {
          if (!hasPermission) {
            return _Info(
              title: 'Se necesita permiso para mostrar tus álbumes.',
              buttonLabel: 'Conceder acceso',
              onPressed: () async {
                await ref
                    .read(mediaPermissionProvider.notifier)
                    .requestAccess();
              },
            );
          }

          final albumsAsync = ref.watch(albumsProvider);
          return albumsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _Info(
              title: 'No se pudieron cargar los álbumes.',
              buttonLabel: 'Reintentar',
              onPressed: () => ref.invalidate(albumsProvider),
            ),
            data: (albums) {
              if (albums.isEmpty) {
                return const Center(child: Text('No se encontraron álbumes.'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(albumsProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: albums.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final a = albums[index];
                    return ListTile(
                      title: Text(a.name),
                      subtitle: Text('${a.count} elementos'),
                      leading: Icon(
                        a.isAll
                            ? Icons.photo_library_outlined
                            : Icons.folder_outlined,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AlbumMediaScreen(
                              albumId: a.id,
                              albumName: a.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
