import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart' show FutureStatus;
import 'package:mocktail/mocktail.dart';
import 'package:product_catalog/models/category.dart';
import 'package:product_catalog/models/product_page.dart';
import 'package:product_catalog/services/api_exception.dart';
import 'package:product_catalog/services/product_service.dart';
import 'package:product_catalog/stores/product_list_store.dart';

import '../helpers/test_data.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  late MockProductService service;
  late ProductListStore store;

  setUp(() {
    service = MockProductService();
    store = ProductListStore(
      service,
      pageSize: 20,
      searchDebounce: Duration.zero,
    );
  });

  tearDown(() => store.dispose());

  /// Asks the controller for a page, as the list view does while scrolling.
  Future<void> requestPage(int skip) async {
    store.paging.notifyPageRequestListeners(skip);
    await pumpEventQueue();
  }

  void stubProducts(ProductPage page) {
    when(
      () => service.getProducts(
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => page);
  }

  group('paging', () {
    test('appends a page and sets the next skip', () async {
      stubProducts(createTestPage(skip: 0, count: 20, total: 194));

      await requestPage(0);

      expect(store.paging.itemList, hasLength(20));
      expect(store.paging.nextPageKey, 20);
      verify(() => service.getProducts(limit: 20, skip: 0)).called(1);
    });

    test('marks the last page so no more requests are made', () async {
      stubProducts(createTestPage(skip: 180, count: 14, total: 194));

      await requestPage(180);

      expect(store.paging.nextPageKey, isNull);
    });

    test('stores the error when a page fails', () async {
      when(
        () => service.getProducts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        ),
      ).thenThrow(const NetworkException());

      await requestPage(0);

      expect(store.paging.error, isA<NetworkException>());
    });
  });

  group('search', () {
    test('searches after the debounce and clears the category', () async {
      when(
        () => service.searchProducts(
          any(),
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        ),
      ).thenAnswer((_) async => createTestPage(skip: 0, count: 3, total: 3));
      store.setCategory('beauty');

      store.setQuery('  phone ');
      await pumpEventQueue();
      await requestPage(0);

      expect(store.categorySlug, isNull);
      expect(store.isSearching, isTrue);
      verify(
        () => service.searchProducts('phone', limit: 20, skip: 0),
      ).called(1);
      expect(store.paging.itemList, hasLength(3));
    });

    test('whitespace-only edits do not reload', () async {
      stubProducts(createTestPage(skip: 0, count: 20, total: 194));
      await requestPage(0);

      store.setQuery('   ');
      await pumpEventQueue();

      expect(store.isSearching, isFalse);
      expect(store.paging.itemList, hasLength(20));
    });
  });

  test('setCategory loads that category and clears the query', () async {
    when(
      () => service.getProductsByCategory(
        any(),
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) async => createTestPage(skip: 0, count: 5, total: 5));
    store.setQuery('phone');

    store.setCategory('laptops');
    await requestPage(0);

    expect(store.query, isEmpty);
    verify(
      () => service.getProductsByCategory('laptops', limit: 20, skip: 0),
    ).called(1);
    expect(store.paging.nextPageKey, isNull);
  });

  test('drops a response that arrives after a reload', () async {
    final slow = Completer<ProductPage>();
    when(
      () => service.getProducts(
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((_) => slow.future);

    unawaited(requestPage(0));
    store.setCategory('beauty');
    slow.complete(createTestPage(skip: 0, count: 20, total: 194));
    await pumpEventQueue();

    expect(store.paging.itemList, isNull);
  });

  group('categories', () {
    test('loads once and is not refetched after success', () async {
      when(() => service.getCategories()).thenAnswer(
        (_) async => const [Category(slug: 'beauty', name: 'Beauty')],
      );

      store.loadCategories();
      await pumpEventQueue();
      store.loadCategories();

      expect(store.categories?.status, FutureStatus.fulfilled);
      expect(store.categories?.value?.single.name, 'Beauty');
      verify(() => service.getCategories()).called(1);
    });

    test('refresh retries categories after a failure', () async {
      when(
        () => service.getCategories(),
      ).thenAnswer((_) async => throw const NetworkException());
      store.loadCategories();
      await pumpEventQueue();
      expect(store.categories?.status, FutureStatus.rejected);

      when(() => service.getCategories()).thenAnswer(
        (_) async => const [Category(slug: 'beauty', name: 'Beauty')],
      );
      await store.refresh();
      await pumpEventQueue();

      expect(store.categories?.status, FutureStatus.fulfilled);
    });
  });
}
