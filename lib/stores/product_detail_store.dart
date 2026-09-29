import 'package:mobx/mobx.dart';
import 'package:product_catalog/models/placeholder_reviews.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/models/review.dart';
import 'package:product_catalog/services/product_service.dart';

part 'product_detail_store.g.dart';

/// Loads the full product for the detail screen.
///
/// [preview] is the product from the list. The screen draws its header from it
/// right away, so the Hero image and title appear before the request finishes.
class ProductDetailStore = _ProductDetailStore with _$ProductDetailStore;

abstract class _ProductDetailStore with Store {
  _ProductDetailStore(this._service, this.preview);

  final ProductService _service;
  final Product preview;

  @observable
  ObservableFuture<Product>? request;

  @computed
  bool get isLoading =>
      request == null || request!.status == FutureStatus.pending;

  @computed
  Object? get error =>
      request?.status == FutureStatus.rejected ? request!.error : null;

  /// The full product once it has loaded, otherwise null.
  @computed
  Product? get product =>
      request?.status == FutureStatus.fulfilled ? request!.value : null;

  /// The loaded product, or the list preview while it loads.
  @computed
  Product get display => product ?? preview;

  /// True when the product has no API reviews and placeholders are shown.
  @computed
  bool get reviewsArePlaceholder => product?.reviews.isEmpty ?? false;

  @computed
  List<Review> get reviews {
    final loaded = product;
    if (loaded == null) return const [];
    return loaded.reviews.isEmpty ? placeholderReviews : loaded.reviews;
  }

  /// Gallery images. Falls back to the thumbnail while loading, and when the
  /// product has no images.
  @computed
  List<String> get images {
    final loaded = product?.images ?? const <String>[];
    return loaded.isEmpty ? [preview.thumbnail] : loaded;
  }

  @action
  void load() {
    request = ObservableFuture(_service.getProduct(preview.id));
  }
}
