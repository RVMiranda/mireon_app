import 'widgets/profile_editor_sheet.dart';
import 'widgets/profile_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/user_profile.dart';
import 'view_models/profiles_providers.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilesNotifierProvider);
    final activeProfile = state.activeProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfiles Locales'),
        actions: [
          IconButton(
            onPressed: () => showProfileEditor(context, ref),
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Crear nuevo perfil',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeProfile != null) ...[
                    Text(
                      'Perfil en uso',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ActiveProfileCard(profile: activeProfile),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Todos los perfiles (${state.profiles.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => showProfileEditor(context, ref),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Nuevo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.profiles.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No hay perfiles locales creados.'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.profiles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final profile = state.profiles[index];
                        final isActive = profile.id == state.activeProfileId;

                        return ProfileListTile(
                          profile: profile,
                          isActive: isActive,
                          onTap: () async {
                            if (!isActive) {
                              await _switchProfile(context, ref, profile);
                            }
                          },
                          onEdit: () =>
                              showProfileEditor(context, ref, profile: profile),
                          onDelete: () => _confirmDelete(context, ref, profile),
                        );
                      },
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProfileEditor(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nuevo Perfil'),
      ),
    );
  }

  Future<void> _switchProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfile target,
  ) async {
    String? secret;
    if (target.isProtected) {
      secret = await _showPinInputDialog(
        context,
        title: 'Perfil protegido',
        subtitle: 'Introduce el PIN o contraseña del perfil.',
      );
      if (secret == null || secret.isEmpty || !context.mounted) return;
    }
    final success = await ref
        .read(profilesNotifierProvider.notifier)
        .setActiveProfile(target.id, pin: secret);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Perfil cambiado a "${target.name}".'
              : ref.read(profilesNotifierProvider).errorMessage ??
                    'No se pudo cambiar de perfil.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    String? currentPin;
    if (profile.isProtected) {
      currentPin = await _showPinInputDialog(
        context,
        title: 'Confirmar identidad',
        subtitle: 'Introduce la credencial del perfil que vas a eliminar.',
      );
      if (currentPin == null || !context.mounted) return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar perfil'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el perfil "${profile.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(profilesNotifierProvider.notifier)
          .deleteProfile(profile.id, currentPin: currentPin);

      if (!context.mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil "${profile.name}" eliminado.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(profilesNotifierProvider).errorMessage ??
                  'No se pudo eliminar el perfil.',
            ),
          ),
        );
      }
    }
  }

  Future<String?> _showPinInputDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) async {
    final pinCtrl = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              enableSuggestions: false,
              autocorrect: false,
              obscureText: true,
              maxLength: 128,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'PIN o contraseña',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(pinCtrl.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    pinCtrl.dispose();
    return result;
  }
}
