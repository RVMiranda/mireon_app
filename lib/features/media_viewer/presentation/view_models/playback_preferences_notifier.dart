import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/playback_preferences.dart';

final playbackPreferencesProvider =
    NotifierProvider<PlaybackPreferencesNotifier, PlaybackPreferences>(
      PlaybackPreferencesNotifier.new,
    );

class PlaybackPreferencesNotifier extends Notifier<PlaybackPreferences> {
  @override
  PlaybackPreferences build() {
    _load();
    return const PlaybackPreferences();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = PlaybackPreferences(
      autoplay: p.getBool('playback.autoplay') ?? true,
      repeat: p.getBool('playback.repeat') ?? false,
      gesturesEnabled: p.getBool('playback.gestures') ?? true,
      gestureSensitivity: p.getDouble('playback.sensitivity') ?? 1.0,
      themeMode: _theme(p.getString('theme.mode')),
      controlsAutoHideSeconds: p.getInt('playback.controlsHideSeconds') ?? 5,
    );
  }

  ThemeMode _theme(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> update({
    bool? autoplay,
    bool? repeat,
    bool? gesturesEnabled,
    double? gestureSensitivity,
    int? controlsAutoHideSeconds,
  }) async {
    state = state.copyWith(
      autoplay: autoplay,
      repeat: repeat,
      gesturesEnabled: gesturesEnabled,
      gestureSensitivity: gestureSensitivity,
      controlsAutoHideSeconds: controlsAutoHideSeconds,
    );
    final p = await SharedPreferences.getInstance();
    await p.setBool('playback.autoplay', state.autoplay);
    await p.setBool('playback.repeat', state.repeat);
    await p.setBool('playback.gestures', state.gesturesEnabled);
    await p.setDouble('playback.sensitivity', state.gestureSensitivity);
    if (state.controlsAutoHideSeconds == null) { await p.remove('playback.controlsHideSeconds'); } else { await p.setInt('playback.controlsHideSeconds', state.controlsAutoHideSeconds!); }
  }

  Future<void> setControlsAutoHide(int? seconds) async {
    state = PlaybackPreferences(
      autoplay: state.autoplay,
      repeat: state.repeat,
      gesturesEnabled: state.gesturesEnabled,
      gestureSensitivity: state.gestureSensitivity,
      themeMode: state.themeMode,
      controlsAutoHideSeconds: seconds,
    );
    final p = await SharedPreferences.getInstance();
    if (seconds == null) { await p.remove('playback.controlsHideSeconds'); } else { await p.setInt('playback.controlsHideSeconds', seconds); }
  }
}
