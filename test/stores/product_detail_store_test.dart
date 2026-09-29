import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_catalog/models/placeholder_reviews.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/models/review.dart';
import 'package:product_catalog/services/api_exception.dart';
import 'package:product_catalog/services/product_service.dart';
import 'package:product_catalog/stores/product_detail_store.dart';

import '../helpers/test_data.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late MockProductService service;
  final preview = createTestProduct(id: 3);

  setUp(() => service = MockProductService());

  Future<ProductDetailStore> loadWith(Product product) async {
    when(() => service.getProduct(3)).thenAnswer((_) async => product);
    final store = ProductDetailStore(service, preview)..load();
    await pumpEventQueue();
    return store;
  }

  test('shows the preview and its thumbnail while loading', () {
    when(() => service.getProduct(3)).thenAnswer((_) => Future.value(preview));
    final store = ProductDetailStore(service, preview)..load();

    expect(store.isLoading, isTrue);
    expect(store.display, same(preview));
    expect(store.images, [preview.thumbnail]);
    expect(store.reviews, isEmpty);
  });

  test('uses the API reviews when there are some', () async {
    final review = Review(
      rating: 5,
      comment: 'Great',
      date: DateTime.utc(2025),
      reviewerName: 'Sam Doe',
    );

    final store = await loadWith(createTestProduct(id: 3, reviews: [review]));

    expect(store.product, isNotNull);
    expect(store.reviews, [review]);
    expect(store.reviewsArePlaceholder, isFalse);
  });

  test('falls back to placeholder reviews when the API has none', () async {
    final store = await loadWith(createTestProduct(id: 3));

    expect(store.reviews, placeholderReviews);
    expect(store.reviewsArePlaceholder, isTrue);
  });

  test('exposes the error and can retry', () async {
    when(
      () => service.getProduct(3),
    ).thenAnswer((_) async => throw const ServerException(500));
    final store = ProductDetailStore(service, preview)..load();
    await pumpEventQueue();

    expect(store.error, isA<ServerException>());
    expect(store.isLoading, isFalse);

    when(() => service.getProduct(3)).thenAnswer((_) async => preview);
    store.load();
    await pumpEventQueue();

    expect(store.error, isNull);
    expect(store.product, same(preview));
  });
}
