import 'package:json_annotation/json_annotation.dart';
import 'package:product_catalog/models/product.dart';

part 'product_page.g.dart';

/// One page of a paginated product response: `{products, total, skip, limit}`.
@JsonSerializable()
class ProductPage {
  const ProductPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductPage.fromJson(Map<String, dynamic> json) =>
      _$ProductPageFromJson(json);

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  /// The offset of the page after this one.
  int get nextSkip => skip + products.length;

  /// Uses the number of products actually returned rather than [limit],
  /// because the API can return fewer items than requested.
  bool get hasMore => products.isNotEmpty && nextSkip < total;
}
