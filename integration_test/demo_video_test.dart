import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:product_catalog/app.dart';
import 'package:product_catalog/config/service_locator.dart';
import 'package:product_catalog/stores/theme_store.dart';
import 'package:product_catalog/widgets/image_gallery.dart';
import 'package:product_catalog/widgets/product_card.dart';
import 'package:product_catalog/widgets/product_card_shimmer.dart';
import 'package:product_catalog/widgets/qr_code_card.dart';
import 'package:product_catalog/widgets/review_tile.dart';

/// A walkthrough paced for a screen recording: the same flow as
/// `app_flow_test.dart`, with smooth drags, typing and pauses.
///
/// Record it with `tool/record_demo.sh`, which writes `docs/demo.mp4`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> hold(WidgetTester tester, int milliseconds) async {
    final end = DateTime.now().add(Duration(milliseconds: milliseconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
    final end = DateTime.now().add(const Duration(seconds: 20));
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) fail('Timed out waiting for $finder');
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// A finger-speed drag, then time for momentum and animations to finish.
  Future<void> swipe(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    int milliseconds = 450,
    int settle = 700,
  }) async {
    await tester.timedDrag(
      finder,
      offset,
      Duration(milliseconds: milliseconds),
    );
    await hold(tester, settle);
  }

  Future<void> type(WidgetTester tester, String text) async {
    for (var i = 1; i <= text.length; i++) {
      await tester.enterText(find.byType(EditableText), text.substring(0, i));
      await hold(tester, 140);
    }
  }

  Finder list() => find.byType(CustomScrollView).first;

  testWidgets('demo walkthrough', (tester) async {
    await setupLocator();
    final themeStore = getIt<ThemeStore>();
    await themeStore.setThemeMode(ThemeMode.light);
    await tester.pumpWidget(App(themeStore: themeStore));

    // First load: skeletons, then the list.
    await pumpUntil(tester, find.byType(ProductCard));
    await hold(tester, 2200);

    // Scroll: the search field hides, then the title folds into the bar.
    await swipe(tester, list(), const Offset(0, -140), settle: 900);
    await swipe(tester, list(), const Offset(0, -420), settle: 1000);

    // Keep going until the next page loads, showing its skeleton cards.
    for (var i = 0; i < 12; i++) {
      if (find.byType(ProductCardShimmer).evaluate().isNotEmpty) break;
      await swipe(
        tester,
        list(),
        const Offset(0, -600),
        milliseconds: 260,
        settle: 350,
      );
    }
    await hold(tester, 1600);

    // Tap the selected chip: back to the top.
    await tester.tap(find.text('All'));
    await hold(tester, 1800);

    // Search: the title slides away and Cancel appears.
    await tester.tap(find.byType(EditableText));
    await hold(tester, 1000);
    await type(tester, 'phone');
    await pumpUntil(tester, find.textContaining('iPhone'));
    await hold(tester, 2200);

    // A search with no results: the empty state.
    await tester.enterText(find.byType(EditableText), '');
    await hold(tester, 300);
    await type(tester, 'zzqxv');
    await pumpUntil(tester, find.text('No products found'));
    await hold(tester, 2200);
    await tester.tap(find.text('Cancel'));
    await hold(tester, 1400);

    // Filter by category.
    await tester.tap(find.text('Furniture'));
    await pumpUntil(tester, find.textContaining('Bed'));
    await hold(tester, 2000);

    // Open a product: the image flies into the gallery.
    await tester.tap(find.byType(ProductCard).first);
    await pumpUntil(tester, find.byType(ReviewTile));
    await hold(tester, 1800);

    // Swipe through the gallery.
    await swipe(
      tester,
      find.byType(ImageGallery),
      const Offset(-300, 0),
      milliseconds: 300,
      settle: 1000,
    );
    await swipe(
      tester,
      find.byType(ImageGallery),
      const Offset(-300, 0),
      milliseconds: 300,
      settle: 1000,
    );

    // Scroll to the reviews and QR code; the gallery collapses into a bar.
    final detail = find.byType(CustomScrollView).last;
    await swipe(tester, detail, const Offset(0, -380), settle: 1200);
    await swipe(tester, detail, const Offset(0, -420), settle: 1200);
    await tester.scrollUntilVisible(
      find.byType(QrCodeCard),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await hold(tester, 1500);

    // Tap a QR code: it opens full screen for scanning.
    await tester.tap(find.text('Generated'));
    await pumpUntil(tester, find.text('Point a camera at the code to scan it'));
    await hold(tester, 2200);
    await tester.tap(find.byTooltip('Close'));
    await hold(tester, 1000);

    // Back to the list.
    await tester.pageBack();
    await hold(tester, 1400);

    // Settings: switch to Dark, then back to Light.
    await tester.tap(find.text('Settings'));
    await hold(tester, 1500);
    await tester.tap(find.text('Dark'));
    await hold(tester, 1800);
    await tester.tap(find.text('Products'));
    await hold(tester, 1800);
    await tester.tap(find.text('Settings'));
    await hold(tester, 900);
    await tester.tap(find.text('Light'));
    await hold(tester, 1600);

    await themeStore.setThemeMode(ThemeMode.system);
  });
}
