import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:product_catalog/screens/home/home_shell.dart';
import 'package:product_catalog/stores/theme_store.dart';
import 'package:product_catalog/theme/app_theme.dart';

/// The root widget. Rebuilds when the theme mode changes.
class App extends StatelessWidget {
  const App({required this.themeStore, super.key});

  final ThemeStore themeStore;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        title: 'Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeStore.themeMode,
        home: const HomeShell(),
      ),
    );
  }
}
