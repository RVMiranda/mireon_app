import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
final appLocaleProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() { _load(); return const Locale('es'); }
  void setLanguage(String language) { state = Locale(language); SharedPreferences.getInstance().then((p) => p.setString('app.language', language)); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); state = Locale(p.getString('app.language') ?? 'es'); }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    SharedPreferences.getInstance().then((prefs) => prefs.setString(
      'theme.mode',
      mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system',
    ));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme.mode');
    state = value == 'light'
        ? ThemeMode.light
        : value == 'dark' ? ThemeMode.dark : ThemeMode.system;
  }
}
