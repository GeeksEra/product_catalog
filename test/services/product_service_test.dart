import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:product_catalog/services/api_client.dart';
import 'package:product_catalog/services/api_exception.dart';
import 'package:product_catalog/services/product_service.dart';

import '../helpers/test_data.dart';

void main() {
  late List<Uri> requests;

  ProductService serviceReturning(
    http.Response Function(Uri uri) respond, {
    Duration timeout = const Duration(seconds: 5),
  }) {
    final client = MockClient((request) async {
      requests.add(request.url);
      return respond(request.url);
    });
    return ProductServiceImpl(ApiClient(client: client, timeout: timeout));
  }

  http.Response json(Object body, [int status = 200]) =>
      http.Response(jsonEncode(body), status);

  Map<String, dynamic> pageJson({int total = 194}) => {
    'products': [productJson(), productJson(id: 2)..remove('brand')],
    'total': total,
    'skip': 0,
    'limit': 2,
  };

  setUp(() => requests = []);

  group('getProducts', () {
    test('sends limit, skip and select, and parses the page', () async {
      final service = serviceReturning((_) => json(pageJson()));

      final page = await service.getProducts(limit: 2, skip: 40);

      final uri = requests.single;
      expect(uri.path, '/products');
      expect(uri.queryParameters['limit'], '2');
      expect(uri.queryParameters['skip'], '40');
      expect(uri.queryParameters['select'], contains('thumbnail'));
      expect(page.products, hasLength(2));
      expect(page.products[1].brand, isNull);
      expect(page.total, 194);
    });

    test('throws ServerException on a 500', () {
      final service = serviceReturning((_) => http.Response('oops', 500));

      expect(
        service.getProducts(limit: 20, skip: 0),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'status', 500),
        ),
      );
    });

    test('throws ParseException on invalid JSON', () {
      final service = serviceReturning((_) => http.Response('<html>', 200));

      expect(
        service.getProducts(limit: 20, skip: 0),
        throwsA(isA<ParseException>()),
      );
    });

    test('throws ParseException when a field has the wrong type', () {
      final service = serviceReturning(
        (_) => json({...pageJson(), 'total': 'many'}),
      );

      expect(
        service.getProducts(limit: 20, skip: 0),
        throwsA(isA<ParseException>()),
      );
    });

    test('throws NetworkException when the connection fails', () {
      final service = ProductServiceImpl(
        ApiClient(
          client: MockClient((_) => throw http.ClientException('offline')),
        ),
      );

      expect(
        service.getProducts(limit: 20, skip: 0),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws NetworkException when the request times out', () {
      final service = ProductServiceImpl(
        ApiClient(
          client: MockClient((_) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return json(pageJson());
          }),
          timeout: const Duration(milliseconds: 1),
        ),
      );

      expect(
        service.getProducts(limit: 20, skip: 0),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  test('searchProducts sends the query to /products/search', () async {
    final service = serviceReturning((_) => json(pageJson()));

    await service.searchProducts('phone case', limit: 20, skip: 0);

    expect(requests.single.path, '/products/search');
    expect(requests.single.queryParameters['q'], 'phone case');
  });

  test('getProductsByCategory uses the category path', () async {
    final service = serviceReturning((_) => json(pageJson()));

    await service.getProductsByCategory('home-decoration', limit: 20, skip: 20);

    expect(requests.single.path, '/products/category/home-decoration');
    expect(requests.single.queryParameters['skip'], '20');
  });

  test('getProduct fetches by id without select', () async {
    final service = serviceReturning((_) => json(productJson(id: 7)));

    final product = await service.getProduct(7);

    expect(requests.single.path, '/products/7');
    expect(requests.single.queryParameters, isEmpty);
    expect(product.id, 7);
    expect(product.reviews, isNotEmpty);
  });

  test('getProduct throws ServerException(404) for an unknown id', () {
    final service = serviceReturning(
      (_) => json({'message': "Product with id '9999' not found"}, 404),
    );

    expect(
      service.getProduct(9999),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'status', 404),
      ),
    );
  });

  test('getCategories parses the list', () async {
    final service = serviceReturning(
      (_) => json([
        {'slug': 'beauty', 'name': 'Beauty', 'url': 'https://x/beauty'},
        {'slug': 'laptops', 'name': 'Laptops', 'url': 'https://x/laptops'},
      ]),
    );

    final categories = await service.getCategories();

    expect(requests.single.path, '/products/categories');
    expect(categories.map((c) => c.slug), ['beauty', 'laptops']);
  });

  test('getCategories throws ParseException when the body is an object', () {
    final service = serviceReturning((_) => json({'categories': <Object>[]}));

    expect(service.getCategories(), throwsA(isA<ParseException>()));
  });
}
