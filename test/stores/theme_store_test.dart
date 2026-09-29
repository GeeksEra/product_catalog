import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/stores/theme_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to system mode', () async {
    SharedPreferences.setMockInitialValues({});
    final store = ThemeStore(await SharedPreferences.getInstance());

    expect(store.themeMode, ThemeMode.system);
  });

  test('restores the saved mode', () async {
    SharedPreferences.setMockInitialValues({themeModeStorageKey: 'dark'});
    final store = ThemeStore(await SharedPreferences.getInstance());

    expect(store.themeMode, ThemeMode.dark);
  });

  test('saves a new mode', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = ThemeStore(prefs);

    await store.setThemeMode(ThemeMode.light);

    expect(store.themeMode, ThemeMode.light);
    expect(prefs.getString(themeModeStorageKey), 'light');
  });
}
