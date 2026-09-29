// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPage _$ProductPageFromJson(Map<String, dynamic> json) => ProductPage(
  products: (json['products'] as List<dynamic>)
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);
