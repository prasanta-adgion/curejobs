import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemePreferenceStorage {
  Future<ThemeMode> getThemeMode(); //read
  Future<void> saveThemeMode(ThemeMode mode); //write
}

final class LocalThemePreferenceStorage implements ThemePreferenceStorage {
  LocalThemePreferenceStorage(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'curejobs_theme_mode';

  @override
  Future<ThemeMode> getThemeMode() async {
    final value = await _prefs.getString(_key);

    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) {
    return _prefs.setString(_key, mode.name);
  }
}
