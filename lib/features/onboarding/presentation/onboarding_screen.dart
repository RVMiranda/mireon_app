import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../profiles/presentation/view_models/profiles_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController(
    text: 'Mi Galería',
  );
  final TextEditingController _pinController = TextEditingController();

  String _selectedIcon = 'person';
  int _selectedColor = 0xFF2196F3;
  bool _enablePin = false;
  bool _isSubmitting = false;

  static const List<(String, IconData, String)> _avatarOptions = [
    ('person', Icons.person_rounded, 'Personal'),
    ('camera', Icons.camera_alt_rounded, 'Fotografía'),
    ('star', Icons.star_rounded, 'Favoritos'),
    ('lock', Icons.lock_rounded, 'Privado'),
    ('palette', Icons.palette_rounded, 'Creativo'),
    ('flame', Icons.local_fire_department_rounded, 'Vibrante'),
    ('shield', Icons.shield_rounded, 'Seguro'),
    ('heart', Icons.favorite_rounded, 'Familiar'),
  ];

  static const List<int> _colorOptions = [
    0xFF2196F3, // Azul
    0xFF9C27B0, // Púrpura
    0xFFE91E63, // Rosa
    0xFF4CAF50, // Verde
    0xFFFF9800, // Naranja
    0xFF607D8B, // Azul Grisáceo
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitInitialProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para tu perfil.')),
      );
      return;
    }

    if (_enablePin && _pinController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener al menos 6 dígitos.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref
          .read(profilesNotifierProvider.notifier)
          .completeOnboarding(
            name: name,
            iconName: _selectedIcon,
            colorValue: _selectedColor,
            pin: _enablePin ? _pinController.text.trim() : null,
          );

      if (!mounted) {
        return;
      }

      if (success) {
        context.go(AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar el perfil.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el perfil.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Galería Media',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          3,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Omitir'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _FeatureSlide(
                    icon: Icons.shield_outlined,
                    iconColor: Colors.blueAccent,
                    title: 'Privacidad Total & Local-First',
                    description:
                        'Tus fotografías y videos nunca salen de tu teléfono. Sin servidores externos, sin rastreo y completamente offline.',
                  ),
                  _FeatureSlide(
                    icon: Icons.play_circle_outline_rounded,
                    iconColor: Colors.purpleAccent,
                    title: 'Reproducción de Video Profesional',
                    description:
                        'Experiencia fluida con gestos táctiles integrados para brillo, volumen, búsqueda fina y zoom continuo.',
                  ),
                  _FeatureSlide(
                    icon: Icons.photo_library_outlined,
                    iconColor: Colors.greenAccent,
                    title: 'Organización & Visor Continuo',
                    description:
                        'Desliza entre fotos y videos en una sola vista. Crea espacios locales independientes para cada ocasión.',
                  ),
                  _ProfileCreationSlide(
                    nameController: _nameController,
                    pinController: _pinController,
                    selectedIcon: _selectedIcon,
                    selectedColor: _selectedColor,
                    enablePin: _enablePin,
                    isSubmitting: _isSubmitting,
                    avatarOptions: _avatarOptions,
                    colorOptions: _colorOptions,
                    onIconSelected: (icon) =>
                        setState(() => _selectedIcon = icon),
                    onColorSelected: (color) =>
                        setState(() => _selectedColor = color),
                    onEnablePinChanged: (val) =>
                        setState(() => _enablePin = val),
                    onSubmit: _submitInitialProfile,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      4,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < 3)
                    FilledButton.icon(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Siguiente'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureSlide extends StatelessWidget {
  const _FeatureSlide({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: iconColor),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileCreationSlide extends StatelessWidget {
  const _ProfileCreationSlide({
    required this.nameController,
    required this.pinController,
    required this.selectedIcon,
    required this.selectedColor,
    required this.enablePin,
    required this.isSubmitting,
    required this.avatarOptions,
    required this.colorOptions,
    required this.onIconSelected,
    required this.onColorSelected,
    required this.onEnablePinChanged,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController pinController;
  final String selectedIcon;
  final int selectedColor;
  final bool enablePin;
  final bool isSubmitting;
  final List<(String, IconData, String)> avatarOptions;
  final List<int> colorOptions;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<bool> onEnablePinChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crea tu Primer Perfil',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Configura tu espacio personal de galería multimedia',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(selectedColor),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getIconData(selectedIcon),
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del perfil',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Selecciona un icono',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: avatarOptions.map((opt) {
              final isSelected = selectedIcon == opt.$1;
              return ChoiceChip(
                showCheckmark: false,
                avatar: Icon(opt.$2, size: 18),
                label: Text(opt.$3),
                selected: isSelected,
                onSelected: (_) => onIconSelected(opt.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Color de fondo',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: colorOptions.map((c) {
              final isSelected = selectedColor == c;
              return GestureDetector(
                onTap: () => onColorSelected(c),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(color: Colors.black38, blurRadius: 6),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Proteger con PIN de seguridad'),
            subtitle: const Text(
              'Requerido al acceder o cambiar a este perfil',
            ),
            value: enablePin,
            onChanged: onEnablePinChanged,
          ),
          if (enablePin) ...[
            const SizedBox(height: 10),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN de seguridad (4 - 6 dígitos)',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                isSubmitting ? 'Guardando...' : 'Comenzar a usar la App',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static IconData _getIconData(String name) {
    return switch (name) {
      'camera' => Icons.camera_alt_rounded,
      'star' => Icons.star_rounded,
      'lock' => Icons.lock_rounded,
      'palette' => Icons.palette_rounded,
      'flame' => Icons.local_fire_department_rounded,
      'shield' => Icons.shield_rounded,
      'heart' => Icons.favorite_rounded,
      _ => Icons.person_rounded,
    };
  }
}
