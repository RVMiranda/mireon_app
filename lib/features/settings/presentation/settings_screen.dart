import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../media_viewer/presentation/view_models/playback_preferences_notifier.dart';
import 'view_models/theme_mode_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final playback = ref.watch(playbackPreferencesProvider);
    final prefs = ref.read(playbackPreferencesProvider.notifier);
    final english = locale.languageCode == 'en';
    return Scaffold(
      appBar: AppBar(title: Text(english ? 'Settings' : 'Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(context, english ? 'Appearance' : 'Apariencia', Icons.palette_outlined, [
            ListTile(
              title: Text(english ? 'Language' : 'Idioma'),
              subtitle: Text(english ? 'Choose the interface language' : 'Selecciona el idioma de la interfaz'),
              trailing: DropdownButton<Locale>(
                value: locale,
                items: const [DropdownMenuItem(value: Locale('es'), child: Text('Español')), DropdownMenuItem(value: Locale('en'), child: Text('English'))],
                onChanged: (value) { if (value != null) ref.read(appLocaleProvider.notifier).setLanguage(value.languageCode); },
              ),
            ),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
              ],
              selected: {theme},
              onSelectionChanged: (value) => ref.read(appThemeModeProvider.notifier).setThemeMode(value.first),
            ),
          ]),
          _section(context, english ? 'Playback' : 'Reproducción', Icons.play_circle_outline, [
            SwitchListTile(title: Text(english ? 'Autoplay' : 'Reproducción automática'), value: playback.autoplay, onChanged: (value) => prefs.update(autoplay: value)),
            SwitchListTile(title: Text(english ? 'Loop videos' : 'Repetir vídeos'), value: playback.repeat, onChanged: (value) => prefs.update(repeat: value)),
            ListTile(title: Text(english ? 'Hide controls after' : 'Ocultar controles después de'), trailing: DropdownButton<int?>(value: playback.controlsAutoHideSeconds, items: const [DropdownMenuItem(value: 3, child: Text('3 s')), DropdownMenuItem(value: 5, child: Text('5 s')), DropdownMenuItem(value: 10, child: Text('10 s')), DropdownMenuItem(value: null, child: Text('Manual'))], onChanged: prefs.setControlsAutoHide)),
          ]),
          _section(context, english ? 'Gestures' : 'Gestos', Icons.gesture, [
            SwitchListTile(title: Text(english ? 'Enable gestures' : 'Activar gestos'), value: playback.gesturesEnabled, onChanged: (value) => prefs.update(gesturesEnabled: value)),
            ListTile(title: Text(english ? 'Sensitivity' : 'Sensibilidad'), subtitle: Slider(value: playback.gestureSensitivity, min: 0.5, max: 2, divisions: 6, onChanged: (value) => prefs.update(gestureSensitivity: value))),
          ]),
          _section(context, 'Biblioteca y privacidad', Icons.photo_library_outlined, [
            const ListTile(title: Text('Permisos y acceso limitado'), subtitle: Text('Gestiona qué contenido puede ver Mireon')),
          ]),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(margin: const EdgeInsets.only(bottom: 14), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]), const SizedBox(height: 8), ...children])));
  }
}
