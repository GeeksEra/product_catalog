import 'package:flutter/material.dart';
import 'package:product_catalog/app.dart';
import 'package:product_catalog/config/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(App(themeStore: getIt()));
}
