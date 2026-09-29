/// DummyJSON endpoints and request settings.
abstract final class ApiConfig {
  static const String baseUrl = 'https://dummyjson.com';
  static const Duration timeout = Duration(seconds: 15);
  static const int pageSize = 20;
  static const Duration searchDebounce = Duration(milliseconds: 400);

  static const String products = '/products';
  static const String search = '/products/search';
  static const String categories = '/products/categories';

  static String product(int id) => '/products/$id';

  static String category(String slug) =>
      '/products/category/${Uri.encodeComponent(slug)}';

  /// Fields the list screen needs. Sending these as `select=` keeps list
  /// payloads small by leaving out reviews, images and other detail-only data.
  static const List<String> listFields = [
    'title',
    'description',
    'price',
    'discountPercentage',
    'brand',
    'category',
    'stock',
    'rating',
    'thumbnail',
  ];
}
