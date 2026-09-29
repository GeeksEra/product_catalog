import 'package:json_annotation/json_annotation.dart';
import 'package:product_catalog/models/product_meta.dart';
import 'package:product_catalog/models/review.dart';

part 'product.g.dart';

/// A DummyJSON product.
///
/// List endpoints are called with `select=` so they return only the fields
/// the product card needs. The detail endpoint returns everything. Fields that
/// can be missing in either case are nullable or have a default.
@JsonSerializable()
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    this.discountPercentage,
    this.brand,
    this.category = '',
    this.images = const [],
    this.reviews = const [],
    this.meta,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  final int id;
  final String title;
  final String description;
  final double price;
  final double? discountPercentage;
  final double rating;
  final int stock;

  /// Missing on roughly half of the catalog, so the UI only shows it when set.
  final String? brand;

  final String category;
  final String thumbnail;
  final List<String> images;
  final List<Review> reviews;
  final ProductMeta? meta;

  /// Availability is derived from [stock], as the brief asks, rather than
  /// taken from the API's own `availabilityStatus` field.
  bool get inStock => stock > 0;

  /// `home-decoration` becomes `Home Decoration`.
  String get categoryLabel => category
      .split('-')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
