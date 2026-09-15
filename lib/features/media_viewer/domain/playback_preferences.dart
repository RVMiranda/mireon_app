import 'package:flutter/material.dart';

class PlaybackPreferences {
  const PlaybackPreferences({
    this.autoplay = true,
    this.repeat = false,
    this.gesturesEnabled = true,
    this.gestureSensitivity = 1.0,
    this.themeMode = ThemeMode.system,
    this.controlsAutoHideSeconds = 5,
  });

  final bool autoplay;
  final bool repeat;
  final bool gesturesEnabled;
  final double gestureSensitivity;
  final ThemeMode themeMode;
  final int? controlsAutoHideSeconds;

  PlaybackPreferences copyWith({
    bool? autoplay,
    bool? repeat,
    bool? gesturesEnabled,
    double? gestureSensitivity,
    ThemeMode? themeMode,
    int? controlsAutoHideSeconds,
  }) => PlaybackPreferences(
    autoplay: autoplay ?? this.autoplay,
    repeat: repeat ?? this.repeat,
    gesturesEnabled: gesturesEnabled ?? this.gesturesEnabled,
    gestureSensitivity: gestureSensitivity ?? this.gestureSensitivity,
    themeMode: themeMode ?? this.themeMode,
    controlsAutoHideSeconds: controlsAutoHideSeconds ?? this.controlsAutoHideSeconds,
  );
}
