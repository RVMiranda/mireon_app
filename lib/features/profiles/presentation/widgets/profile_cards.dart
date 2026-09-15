import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/user_profile.dart';

class ActiveProfileCard extends StatelessWidget {
  const ActiveProfileCard({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(profile.colorValue).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(profile.colorValue).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(profile.colorValue),
              shape: BoxShape.circle,
            ),
            child: _avatar(profile.iconName, Colors.white, 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (profile.isProtected) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.isProtected
                      ? 'Perfil protegido por PIN'
                      : 'Perfil sin contraseña',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Activo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getIcon(String name) {
    return switch (name) {
      'camera' => Icons.camera_alt_rounded,
      'star' => Icons.star_rounded,
      'lock' => Icons.lock_rounded,
      'palette' => Icons.palette_rounded,
      'flame' => Icons.local_fire_department_rounded,
      'shield' => Icons.shield_rounded,
      _ => Icons.person_rounded,
    };
  }

  static Widget _avatar(String name, Color color, double size) {
    const paths = <String, String>{'atom':'resources/profile/atom-svgrepo-com.svg','ghost':'resources/profile/ghost-smile-svgrepo-com.svg','incognito':'resources/profile/incognito-svgrepo-com.svg','masks':'resources/profile/masks-svgrepo-com.svg','meditation':'resources/profile/meditation-round-svgrepo-com.svg','rocket':'resources/profile/rocket-2-svgrepo-com.svg','smile':'resources/profile/smile-square-svgrepo-com.svg','gameboy':'resources/profile/gameboy-svgrepo-com.svg','face':'resources/profile/face-scan-square-svgrepo-com.svg','balls':'resources/profile/balls-svgrepo-com.svg','emoji':'resources/profile/emoji-funny-square-svgrepo-com.svg','person':'resources/profile/user-svgrepo-com.svg'};
    final path = paths[name];
    return path == null ? Icon(_getIcon(name), color: color, size: size) : SvgPicture.asset(path, width: size, height: size, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }
}

class ProfileListTile extends StatelessWidget {
  const ProfileListTile({
    super.key,
    required this.profile,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final UserProfile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? Theme.of(context).colorScheme.surfaceContainerHigh
          : Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(profile.colorValue),
                  shape: BoxShape.circle,
                ),
                child: ActiveProfileCard._avatar(profile.iconName, Colors.white, 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: TextStyle(
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        if (profile.isProtected) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive ? 'Perfil activo actual' : 'Toca para activar',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: onDelete,
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
