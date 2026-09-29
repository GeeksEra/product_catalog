import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:product_catalog/config/service_locator.dart';
import 'package:product_catalog/screens/home/home_shell.dart';
import 'package:product_catalog/services/product_service.dart';
import 'package:product_catalog/stores/product_list_store.dart';
import 'package:product_catalog/stores/theme_store.dart';
import 'package:product_catalog/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_data.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final service = MockProductService();
    when(service.getCategories).thenAnswer((_) async => const []);
    when(
      () => service.getProducts(
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => createTestPage(skip: 0, count: 3, total: 3));
    getIt
      ..registerSingleton<ThemeStore>(
        ThemeStore(await SharedPreferences.getInstance()),
      )
      ..registerSingleton<PackageInfo>(
        PackageInfo(
          appName: 'Product Catalog',
          packageName: 'com.geeksera.product_catalog',
          version: '1.0.0',
          buildNumber: '1',
        ),
      )
      ..registerFactory<ProductListStore>(
        () => ProductListStore(
          service,
          pageSize: 20,
          searchDebounce: Duration.zero,
        ),
      );
  });

  /// Pumps the shell and records the last "can the app handle back?" answer
  /// it would send to the platform (Android predictive back).
  Future<List<bool>> pumpShell(WidgetTester tester) async {
    final reports = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: NotificationListener<NavigationNotification>(
          onNotification: (notification) {
            reports.add(notification.canHandlePop);
            return true;
          },
          child: const HomeShell(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return reports;
  }

  testWidgets('on the Settings tab the app keeps the back gesture', (
    tester,
  ) async {
    final reports = await pumpShell(tester);

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Otherwise Android would close the app instead of returning to Products.
    expect(reports.last, isTrue);
  });

  testWidgets('back from Settings returns to Products', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Appearance'.toUpperCase()), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Product 1'), findsOneWidget);
  });
}
