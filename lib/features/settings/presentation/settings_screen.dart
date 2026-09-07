import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/section_placeholder_page.dart';
import 'view_models/theme_mode_notifier.dart';
import '../../media_viewer/presentation/view_models/playback_preferences_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final playback = ref.watch(playbackPreferencesProvider);

    return SectionPlaceholderPage(
      title: 'Ajustes',
      description: 'Preferencias locales de apariencia, reproducción y gestos.',
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
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Reproducción automática'),
          value: playback.autoplay,
          onChanged: (value) => ref.read(playbackPreferencesProvider.notifier).update(autoplay: value),
        ),
        SwitchListTile(
          title: const Text('Repetir vídeos'),
          value: playback.repeat,
          onChanged: (value) => ref.read(playbackPreferencesProvider.notifier).update(repeat: value),
        ),
        SwitchListTile(
          title: const Text('Gestos del reproductor'),
          value: playback.gesturesEnabled,
          onChanged: (value) => ref.read(playbackPreferencesProvider.notifier).update(gesturesEnabled: value),
        ),
        ListTile(
          title: const Text('Sensibilidad de gestos'),
          subtitle: Slider(
            value: playback.gestureSensitivity,
            min: 0.5,
            max: 2,
            divisions: 6,
            label: playback.gestureSensitivity.toStringAsFixed(1),
            onChanged: (value) => ref.read(playbackPreferencesProvider.notifier).update(gestureSensitivity: value),
          ),
        ),
      ],
    );
  }
}
