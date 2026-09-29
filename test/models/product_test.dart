import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/models/product_page.dart';

import '../helpers/test_data.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a full detail response', () {
      final product = Product.fromJson(productJson());

      expect(product.id, 1);
      expect(product.brand, 'Essence');
      expect(product.price, 9.99);
      expect(product.images, hasLength(1));
      expect(product.reviews.single.reviewerName, 'Lucas Gordon');
      expect(
        product.reviews.single.date,
        DateTime.utc(2025, 4, 30, 9, 41, 2, 53),
      );
      expect(product.meta?.barcode, '5784719087687');
    });

    test('leaves brand null when the API omits it', () {
      final product = Product.fromJson(productJson()..remove('brand'));

      expect(product.brand, isNull);
    });

    test('defaults the fields that list responses leave out', () {
      final json = productJson()
        ..remove('images')
        ..remove('reviews')
        ..remove('meta')
        ..remove('category');

      final product = Product.fromJson(json);

      expect(product.images, isEmpty);
      expect(product.reviews, isEmpty);
      expect(product.meta, isNull);
      expect(product.category, '');
    });

    test('accepts whole-number prices', () {
      final product = Product.fromJson(productJson()..['price'] = 5);

      expect(product.price, 5.0);
    });
  });

  group('Product.inStock', () {
    test('is true when stock is above zero', () {
      expect(createTestProduct(stock: 1).inStock, isTrue);
    });

    test('is false when stock is zero', () {
      expect(createTestProduct(stock: 0).inStock, isFalse);
    });
  });

  test('categoryLabel turns the slug into words', () {
    expect(createTestProduct().categoryLabel, 'Home Decoration');
  });

  group('ProductPage.hasMore', () {
    test('is true while items remain', () {
      final page = createTestPage(skip: 0, count: 20, total: 194);

      expect(page.hasMore, isTrue);
      expect(page.nextSkip, 20);
    });

    test('is false on the last page', () {
      final page = createTestPage(skip: 180, count: 14, total: 194);

      expect(page.hasMore, isFalse);
    });

    test('is false for an empty page', () {
      const page = ProductPage(products: [], total: 0, skip: 0, limit: 0);

      expect(page.hasMore, isFalse);
    });
  });
}
