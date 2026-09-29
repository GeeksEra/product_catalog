import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/models/product_page.dart';
import 'package:product_catalog/models/review.dart';

/// Product JSON shaped like the DummyJSON detail response.
Map<String, dynamic> productJson({
  int id = 1,
  int stock = 99,
  bool withReviews = true,
}) {
  return {
    'id': id,
    'title': 'Essence Mascara Lash Princess',
    'description': 'A popular mascara known for its volumizing effects.',
    'category': 'beauty',
    'price': 9.99,
    'discountPercentage': 10.48,
    'rating': 2.56,
    'stock': stock,
    'brand': 'Essence',
    'thumbnail': 'https://cdn.dummyjson.com/p/$id/thumbnail.webp',
    'images': ['https://cdn.dummyjson.com/p/$id/1.webp'],
    'reviews': withReviews
        ? [
            {
              'rating': 4,
              'comment': 'Very satisfied!',
              'date': '2025-04-30T09:41:02.053Z',
              'reviewerName': 'Lucas Gordon',
              'reviewerEmail': 'lucas.gordon@x.dummyjson.com',
            },
          ]
        : <Object>[],
    'meta': {
      'barcode': '5784719087687',
      'qrCode': 'https://cdn.dummyjson.com/public/qr-code.png',
    },
  };
}

Product createTestProduct({
  int id = 1,
  String title = 'Test product',
  String? brand = 'Acme',
  int stock = 5,
  double price = 19.99,
  double rating = 4.5,
  List<Review> reviews = const [],
}) {
  return Product(
    id: id,
    title: title,
    description: 'A short description of the test product.',
    price: price,
    rating: rating,
    stock: stock,
    brand: brand,
    category: 'home-decoration',
    thumbnail: 'https://example.com/$id.webp',
    reviews: reviews,
  );
}

ProductPage createTestPage({
  required int skip,
  required int count,
  required int total,
}) {
  return ProductPage(
    products: [
      for (var i = 0; i < count; i++)
        createTestProduct(id: skip + i + 1, title: 'Product ${skip + i + 1}'),
    ],
    total: total,
    skip: skip,
    limit: count,
  );
}
