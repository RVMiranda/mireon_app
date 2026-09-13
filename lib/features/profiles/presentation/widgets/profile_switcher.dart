import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/profiles_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';

class ProfileSwitcher extends ConsumerWidget {
  const ProfileSwitcher({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilesNotifierProvider);
    final active = state.activeProfile;
    if (active == null) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      tooltip: 'Cambiar perfil',
      onSelected: (id) async {
        if (id == '_manage') { if (context.mounted) context.push(AppRoutes.profiles); return; }
        await ref.read(profilesNotifierProvider.notifier).setActiveProfile(id);
      },
      itemBuilder: (_) => [
        ...state.profiles.map((p) => PopupMenuItem(value: p.id, child: Text(p.name))),
        const PopupMenuDivider(),
        const PopupMenuItem(value: '_manage', child: Text('Administrar perfiles')),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CircleAvatar(
          radius: 17,
          child: Text(active.name.characters.first.toUpperCase()),
        ),
      ),
    );
  }
}
