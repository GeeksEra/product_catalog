import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:product_catalog/app.dart';
import 'package:product_catalog/config/service_locator.dart';
import 'package:product_catalog/stores/theme_store.dart';
import 'package:product_catalog/widgets/product_card.dart';
import 'package:product_catalog/widgets/product_card_shimmer.dart';
import 'package:product_catalog/widgets/qr_code_card.dart';
import 'package:product_catalog/widgets/review_tile.dart';

/// End-to-end run against the live DummyJSON API. It also captures the README
/// screenshots.
///
/// ```sh
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/app_flow_test.dart
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps frames until [finder] matches. `pumpAndSettle` never settles here,
  /// because shimmer placeholders animate forever.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        fail('Timed out waiting for $finder');
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Pumps frames for [duration]: lets images decode and animations finish.
  Future<void> wait(
    WidgetTester tester, [
    Duration duration = const Duration(milliseconds: 2500),
  ]) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> screenshot(String name) => binding.takeScreenshot(name);

  Finder productList() => find.byType(CustomScrollView).first;

  testWidgets('browse, search, filter, open a product and change settings', (
    tester,
  ) async {
    await setupLocator();
    final themeStore = getIt<ThemeStore>();
    await themeStore.setThemeMode(ThemeMode.light);
    await tester.pumpWidget(App(themeStore: themeStore));

    // List with the large title and search field.
    await pumpUntil(tester, find.byType(ProductCard));
    await wait(tester);
    await screenshot('01_list');

    // Scrolling hides the search field and folds the title into the bar.
    await tester.drag(productList(), const Offset(0, -260));
    await wait(tester, const Duration(milliseconds: 1500));
    await screenshot('02_list_scrolled');

    // Load more: skeleton cards at the end while the next page loads.
    for (var i = 0; i < 40; i++) {
      if (find.byType(ProductCardShimmer).evaluate().isNotEmpty) break;
      await tester.drag(productList(), const Offset(0, -700));
      await tester.pump(const Duration(milliseconds: 16));
    }
    if (find.byType(ProductCardShimmer).evaluate().isNotEmpty) {
      await screenshot('03_load_more');
    }

    // Tapping the selected chip scrolls back to the top.
    await wait(tester, const Duration(milliseconds: 1500));
    await tester.tap(find.text('All'));
    await wait(tester, const Duration(milliseconds: 1200));
    expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);

    await themeStore.setThemeMode(ThemeMode.dark);
    await wait(tester, const Duration(milliseconds: 1200));
    await screenshot('04_list_dark');
    await themeStore.setThemeMode(ThemeMode.light);

    // Focusing search slides the title away and pins the field with Cancel.
    await tester.tap(find.byType(EditableText));
    await wait(tester, const Duration(milliseconds: 800));
    expect(find.text('Cancel'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'phone');
    await pumpUntil(tester, find.textContaining('iPhone'));
    await wait(tester);
    await screenshot('05_search');

    // A search with no results shows the empty state.
    await tester.enterText(find.byType(EditableText), 'zzqxv');
    await pumpUntil(tester, find.text('No products found'));
    await wait(tester, const Duration(milliseconds: 800));
    await screenshot('06_search_empty');

    await tester.tap(find.text('Cancel'));
    await wait(tester, const Duration(milliseconds: 800));
    expect(find.text('Cancel'), findsNothing);

    // Category filter.
    await tester.tap(find.text('Furniture'));
    await pumpUntil(tester, find.textContaining('Bed'));
    await wait(tester);
    await screenshot('07_category');

    // Detail: the gallery, then the collapsed bar over reviews and QR code.
    await tester.tap(find.byType(ProductCard).first);
    await pumpUntil(tester, find.byType(ReviewTile));
    await wait(tester);
    await screenshot('08_detail');

    await tester.scrollUntilVisible(
      find.byType(QrCodeCard),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await wait(tester);
    await screenshot('09_detail_reviews_qr');

    // Tapping a QR code shows it full screen for scanning.
    await tester.tap(find.text('Generated'));
    await pumpUntil(tester, find.text('Point a camera at the code to scan it'));
    await wait(tester, const Duration(milliseconds: 800));
    await screenshot('10_qr_fullscreen');
    await tester.tap(find.byTooltip('Close'));
    await wait(tester, const Duration(milliseconds: 800));

    await themeStore.setThemeMode(ThemeMode.dark);
    await wait(tester, const Duration(milliseconds: 1200));
    await screenshot('11_detail_dark');
    await themeStore.setThemeMode(ThemeMode.light);

    // Settings tab, then pick Dark from the appearance previews.
    await tester.tap(find.text('Settings'));
    await wait(tester, const Duration(milliseconds: 1200));
    await screenshot('12_settings');

    await tester.tap(find.text('Dark'));
    await wait(tester, const Duration(milliseconds: 1200));
    expect(themeStore.themeMode, ThemeMode.dark);
    await screenshot('13_settings_dark');

    // Leave the simulator on the default setting.
    await themeStore.setThemeMode(ThemeMode.system);
  });
}
