import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/theme/app_theme.dart';
import 'package:product_catalog/widgets/price_text.dart';
import 'package:product_catalog/widgets/product_card.dart';

import '../helpers/test_data.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    Product product, {
    VoidCallback? onTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ProductCard(product: product, onTap: onTap ?? () {}),
        ),
      ),
    );
  }

  testWidgets('shows title, brand, price, rating and stock', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpCard(tester, createTestProduct(title: 'Desk Lamp'));

    expect(find.text('Desk Lamp'), findsOneWidget);
    expect(find.text('ACME'), findsOneWidget);
    expect(find.text('\$19.99'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('In Stock'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Rated 4.5 out of 5')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('hides the brand when there is none', (tester) async {
    await pumpCard(tester, createTestProduct(brand: null));

    expect(find.text('ACME'), findsNothing);
  });

  testWidgets('shows Out of Stock when stock is zero', (tester) async {
    await pumpCard(tester, createTestProduct(stock: 0));

    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.text('In Stock'), findsNothing);
  });

  testWidgets('calls onTap', (tester) async {
    var taps = 0;
    await pumpCard(tester, createTestProduct(), onTap: () => taps++);

    await tester.tap(find.byType(ProductCard));

    expect(taps, 1);
  });

  testWidgets('fits a small phone at 1.3x text scale', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Scaffold(
            body: ProductCard(product: createTestProduct(), onTap: () {}),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  test('formatPrice groups thousands', () {
    expect(formatPrice(9.99), '\$9.99');
    expect(formatPrice(1899.99), '\$1,899.99');
    expect(formatPrice(1234567), '\$1,234,567.00');
  });
}
