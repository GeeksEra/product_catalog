import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// A product category from `GET /products/categories`.
@JsonSerializable()
class Category {
  const Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  final String slug;
  final String name;
}
