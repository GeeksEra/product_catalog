import 'package:json_annotation/json_annotation.dart';

part 'product_meta.g.dart';

/// The `meta` object of a product. Only the fields the app shows are mapped.
@JsonSerializable()
class ProductMeta {
  const ProductMeta({this.barcode, this.qrCode});

  factory ProductMeta.fromJson(Map<String, dynamic> json) =>
      _$ProductMetaFromJson(json);

  final String? barcode;

  /// URL of a QR code image. DummyJSON returns the same placeholder image for
  /// every product.
  final String? qrCode;
}
