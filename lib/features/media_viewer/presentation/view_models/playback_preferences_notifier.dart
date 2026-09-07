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
  }) async {
    state = state.copyWith(
      autoplay: autoplay,
      repeat: repeat,
      gesturesEnabled: gesturesEnabled,
      gestureSensitivity: gestureSensitivity,
    );
    final p = await SharedPreferences.getInstance();
    await p.setBool('playback.autoplay', state.autoplay);
    await p.setBool('playback.repeat', state.repeat);
    await p.setBool('playback.gestures', state.gesturesEnabled);
    await p.setDouble('playback.sensitivity', state.gestureSensitivity);
  }
}
