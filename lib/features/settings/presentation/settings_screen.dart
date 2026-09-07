import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_placeholder_page.dart';
import 'view_models/theme_mode_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return SectionPlaceholderPage(
      title: 'Ajustes',
      description:
          'Configuracion base de Fase 1. Aqui se ampliaran privacidad, seguridad y reproduccion.',
      actions: [
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text('Sistema'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('Claro'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('Oscuro'),
            ),
          ],
          selected: <ThemeMode>{themeMode},
          onSelectionChanged: (selection) {
            ref
                .read(appThemeModeProvider.notifier)
                .setThemeMode(selection.first);
          },
        ),
      ],
    );
  }
}
