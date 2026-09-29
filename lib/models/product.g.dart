// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  rating: (json['rating'] as num).toDouble(),
  stock: (json['stock'] as num).toInt(),
  thumbnail: json['thumbnail'] as String,
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
  brand: json['brand'] as String?,
  category: json['category'] as String? ?? '',
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? null
      : ProductMeta.fromJson(json['meta'] as Map<String, dynamic>),
);
