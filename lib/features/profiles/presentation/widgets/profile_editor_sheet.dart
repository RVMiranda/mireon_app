import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../view_models/profiles_providers.dart';

Future<void> showProfileEditor(
  BuildContext context,
  WidgetRef ref, {
  UserProfile? profile,
}) async {
  final isEditing = profile != null;
  final nameCtrl = TextEditingController(text: profile?.name ?? '');
  final pinCtrl = TextEditingController();
  final currentPinCtrl = TextEditingController();

  String selectedIcon = profile?.iconName ?? 'person';
  int selectedColor = profile?.colorValue ?? 0xFF2196F3;
  bool enablePin = profile?.isProtected ?? false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 10,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Editar Perfil' : 'Crear Perfil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del perfil',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Icono del perfil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _avatarIcons.map((opt) {
                      final isSel = selectedIcon == opt.$1;
                      return ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(opt.$2, size: 16),
                        label: Text(opt.$3),
                        selected: isSel,
                        onSelected: (_) =>
                            setModalState(() => selectedIcon = opt.$1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Color de perfil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _colors.map((c) {
                      final isSel = selectedColor == c;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = c),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: isSel
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Proteger con PIN o contraseña'),
                    value: enablePin,
                    onChanged: (val) => setModalState(() => enablePin = val),
                  ),
                  if (enablePin) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: pinCtrl,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      maxLength: 128,
                      decoration: InputDecoration(
                        labelText: isEditing
                            ? 'Nueva credencial (vacío para mantener actual)'
                            : 'PIN o contraseña',
                        helperText:
                            'PIN: 6–12 dígitos. Contraseña: 10–128 caracteres.',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                  if (profile?.isProtected == true) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: currentPinCtrl,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'PIN o contraseña actual',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            return;
                          }

                          final notifier = ref.read(
                            profilesNotifierProvider.notifier,
                          );

                          final bool success;
                          if (isEditing) {
                            success = await notifier.updateProfile(
                              profile,
                              name: name,
                              iconName: selectedIcon,
                              colorValue: selectedColor,
                              currentPin: currentPinCtrl.text,
                              newPin:
                                  enablePin &&
                                      (pinCtrl.text.isNotEmpty ||
                                          !profile.isProtected)
                                  ? pinCtrl.text
                                  : null,
                              clearPin: !enablePin,
                            );
                          } else {
                            success =
                                await notifier.createProfile(
                                  name: name,
                                  iconName: selectedIcon,
                                  colorValue: selectedColor,
                                  pin: enablePin ? pinCtrl.text : null,
                                ) !=
                                null;
                          }

                          if (!success && ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ref
                                          .read(profilesNotifierProvider)
                                          .errorMessage ??
                                      'No se pudo guardar el perfil.',
                                ),
                              ),
                            );
                          }
                          if (success && ctx.mounted) {
                            Navigator.of(ctx).pop();
                          }
                        },
                        child: Text(isEditing ? 'Guardar' : 'Crear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  nameCtrl.dispose();
  pinCtrl.dispose();
  currentPinCtrl.dispose();
}

const List<(String, IconData, String)> _avatarIcons = [
  ('person', Icons.person_rounded, 'Personal'),
  ('camera', Icons.camera_alt_rounded, 'Fotos'),
  ('star', Icons.star_rounded, 'Favoritos'),
  ('lock', Icons.lock_rounded, 'Privado'),
  ('palette', Icons.palette_rounded, 'Arte'),
  ('flame', Icons.local_fire_department_rounded, 'Vibrante'),
  ('shield', Icons.shield_rounded, 'Seguro'),
];

const List<int> _colors = [
  0xFF2196F3,
  0xFF9C27B0,
  0xFFE91E63,
  0xFF4CAF50,
  0xFFFF9800,
  0xFF607D8B,
];
