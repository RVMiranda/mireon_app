import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../albums/presentation/view_models/albums_providers.dart';
import '../../media_library/domain/entities/media_filter.dart';
import '../../media_library/presentation/view_models/media_gallery_notifier.dart';
import '../../media_library/presentation/view_models/media_permission_notifier.dart';
import '../../media_library/presentation/widgets/media_search_delegate.dart';
import '../../profiles/presentation/view_models/profiles_providers.dart';
import 'widgets/collections_section.dart';
import 'widgets/recent_media_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getDynamicGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Buen día, $name';
    } else if (hour >= 12 && hour < 19) {
      return 'Buenas tardes, $name';
    } else {
      return 'Gran noche, $name';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(mediaPermissionProvider);
    final activeProfile = ref.watch(profilesNotifierProvider).activeProfile;
    final profileName = activeProfile?.name ?? 'Galería';
    final greeting = _getDynamicGreeting(profileName);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          greeting,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: MediaSearchDelegate(ref: ref),
              );
            },
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Buscar contenido',
          ),
          if (activeProfile != null)
            PopupMenuButton<String>(
              tooltip: 'Perfil activo',
              onSelected: (value) async {
                if (value == 'manage') {
                  if (context.mounted) context.push(AppRoutes.profiles);
                  return;
                }
                await ref.read(profilesNotifierProvider.notifier).setActiveProfile(value);
              },
              itemBuilder: (_) {
                final profiles = ref.read(profilesNotifierProvider).profiles;
                return [
                  ...profiles.map((profile) => PopupMenuItem<String>(
                    value: profile.id,
                    child: Row(children: [Icon(profile.isProtected ? Icons.lock_outline : Icons.person_outline, size: 20), const SizedBox(width: 10), Text(profile.name)]),
                  )),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(value: 'manage', child: Text('Administrar perfiles')),
                ];
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(activeProfile.name.characters.first.toUpperCase()),
                ),
              ),
            ),
        ],
      ),
      body: permissionState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.orangeAccent),
                const SizedBox(height: 12),
                const Text(
                  'No se pudo comprobar el permiso de biblioteca.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(mediaPermissionProvider.notifier).refreshStatus(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (hasPermission) {
          if (!hasPermission) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Acceso a la Galería Multimedia',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Para mostrar tus fotos, videos y álbumes locales, otorga acceso a los archivos multimedia de tu dispositivo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(mediaPermissionProvider.notifier)
                            .requestAccess();
                      },
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Conceder Acceso'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(albumsProvider);
              await ref
                  .read(mediaGalleryProvider(MediaFilter.all).notifier)
                  .refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RecentMediaSection(),
                    const SizedBox(height: 16),
                    const CollectionsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopQuickAccessBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickAccessChip(
              icon: Icons.person_outline_rounded,
              label: 'Perfiles',
              color: Theme.of(context).colorScheme.secondaryContainer,
              onTap: () => context.push(AppRoutes.profiles),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickAccessChip(
              icon: Icons.folder_open_rounded,
              label: 'Archivos',
              color: Theme.of(context).colorScheme.tertiaryContainer,
              onTap: () => context.push(AppRoutes.files),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessChip extends StatelessWidget {
  const _QuickAccessChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
