import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_store.g.dart';

/// Where the chosen [ThemeMode] is saved.
const String themeModeStorageKey = 'theme_mode';

/// Holds the user's System / Light / Dark choice and saves it across launches.
class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  _ThemeStore(this._prefs) : themeMode = _read(_prefs);

  final SharedPreferences _prefs;

  @observable
  ThemeMode themeMode;

  @action
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _prefs.setString(themeModeStorageKey, mode.name);
  }

  static ThemeMode _read(SharedPreferences prefs) {
    final saved = prefs.getString(themeModeStorageKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }
}
