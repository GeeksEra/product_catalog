import 'package:product_catalog/config/api_config.dart';
import 'package:product_catalog/models/category.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/models/product_page.dart';
import 'package:product_catalog/services/api_client.dart';
import 'package:product_catalog/services/api_exception.dart';

/// Read access to the DummyJSON product catalog.
///
/// Every method throws an [ApiException] on failure.
abstract interface class ProductService {
  Future<ProductPage> getProducts({required int limit, required int skip});

  Future<ProductPage> searchProducts(
    String query, {
    required int limit,
    required int skip,
  });

  Future<ProductPage> getProductsByCategory(
    String slug, {
    required int limit,
    required int skip,
  });

  Future<Product> getProduct(int id);

  Future<List<Category>> getCategories();
}

/// [ProductService] backed by the DummyJSON REST API.
class ProductServiceImpl implements ProductService {
  ProductServiceImpl(this._client);

  final ApiClient _client;

  @override
  Future<ProductPage> getProducts({required int limit, required int skip}) {
    return _getPage(ApiConfig.products, limit: limit, skip: skip);
  }

  @override
  Future<ProductPage> searchProducts(
    String query, {
    required int limit,
    required int skip,
  }) {
    return _getPage(
      ApiConfig.search,
      limit: limit,
      skip: skip,
      extra: {'q': query},
    );
  }

  @override
  Future<ProductPage> getProductsByCategory(
    String slug, {
    required int limit,
    required int skip,
  }) {
    return _getPage(ApiConfig.category(slug), limit: limit, skip: skip);
  }

  @override
  Future<Product> getProduct(int id) async {
    final json = await _client.getObject(ApiConfig.product(id));
    return _parse(() => Product.fromJson(json));
  }

  @override
  Future<List<Category>> getCategories() async {
    final json = await _client.getList(ApiConfig.categories);
    return _parse(
      () => json
          .cast<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList(growable: false),
    );
  }

  Future<ProductPage> _getPage(
    String path, {
    required int limit,
    required int skip,
    Map<String, String> extra = const {},
  }) async {
    final json = await _client.getObject(
      path,
      query: {
        ...extra,
        'limit': '$limit',
        'skip': '$skip',
        'select': ApiConfig.listFields.join(','),
      },
    );
    return _parse(() => ProductPage.fromJson(json));
  }

  /// Generated `fromJson` code throws [TypeError] when a field has the wrong
  /// type or is missing. That is reported to callers as a [ParseException].
  T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on TypeError {
      throw const ParseException();
    }
  }
}
