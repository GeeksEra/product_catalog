import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_catalog/config/service_locator.dart';
import 'package:product_catalog/models/category.dart';
import 'package:product_catalog/models/product_page.dart';
import 'package:product_catalog/screens/product_list/product_list_screen.dart';
import 'package:product_catalog/services/product_service.dart';
import 'package:product_catalog/stores/product_list_store.dart';
import 'package:product_catalog/theme/app_theme.dart';
import 'package:product_catalog/widgets/product_card_shimmer.dart';

import '../helpers/test_data.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late MockProductService service;
  late Completer<ProductPage> secondPage;

  setUp(() async {
    await getIt.reset();
    service = MockProductService();
    when(
      () => service.getCategories(),
    ).thenAnswer((_) async => const [Category(slug: 'beauty', name: 'Beauty')]);
    when(
      () => service.getProducts(limit: 20, skip: 0),
    ).thenAnswer((_) async => createTestPage(skip: 0, count: 20, total: 40));
    when(
      () => service.getProducts(limit: 20, skip: 20),
    ).thenAnswer((_) => secondPage.future);
    getIt.registerFactory<ProductListStore>(
      () => ProductListStore(
        service,
        pageSize: 20,
        searchDebounce: Duration.zero,
      ),
    );
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    // Created here, inside the test body, so completing it runs its callbacks
    // in the test's fake-async zone. A Completer made in setUp would complete
    // on the real microtask queue, which `tester.pump` never drains.
    secondPage = Completer<ProductPage>();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const ProductListScreen()),
    );
    // Shimmer animates forever, so pump frames instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Drags up until [finder] shows, or gives up after [maxDrags].
  Future<void> scrollUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxDrags = 40,
  }) async {
    for (var i = 0; i < maxDrags && finder.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('shows skeleton cards while the next page loads', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Product 1'), findsOneWidget);

    await scrollUntilFound(tester, find.byType(ProductCardShimmer));
    expect(find.byType(ProductCardShimmer), findsWidgets);

    secondPage.complete(createTestPage(skip: 20, count: 20, total: 40));
    await tester.pump();
    // Lets the indicator's fade-out transition finish.
    await tester.pump(const Duration(seconds: 1));
    await scrollUntilFound(tester, find.text("That's all 40 products"));

    expect(find.byType(ProductCardShimmer), findsNothing);
    expect(find.text("That's all 40 products"), findsOneWidget);
  });

  testWidgets('tapping the selected chip scrolls back to the top', (
    tester,
  ) async {
    await pumpScreen(tester);
    await scrollUntilFound(tester, find.text('Product 12'));
    expect(find.text('Product 1'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Product 1'), findsOneWidget);
    verifyNever(
      () => service.getProductsByCategory(
        any(),
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    );
  });

  testWidgets('focusing search shows Cancel, which ends the search', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Cancel'), findsNothing);

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Cancel'), findsNothing);
  });
}
