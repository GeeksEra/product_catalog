// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductDetailStore on _ProductDetailStore, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading => (_$isLoadingComputed ??= Computed<bool>(
    () => super.isLoading,
    name: '_ProductDetailStore.isLoading',
  )).value;
  Computed<Object?>? _$errorComputed;

  @override
  Object? get error => (_$errorComputed ??= Computed<Object?>(
    () => super.error,
    name: '_ProductDetailStore.error',
  )).value;
  Computed<Product?>? _$productComputed;

  @override
  Product? get product => (_$productComputed ??= Computed<Product?>(
    () => super.product,
    name: '_ProductDetailStore.product',
  )).value;
  Computed<Product>? _$displayComputed;

  @override
  Product get display => (_$displayComputed ??= Computed<Product>(
    () => super.display,
    name: '_ProductDetailStore.display',
  )).value;
  Computed<bool>? _$reviewsArePlaceholderComputed;

  @override
  bool get reviewsArePlaceholder =>
      (_$reviewsArePlaceholderComputed ??= Computed<bool>(
        () => super.reviewsArePlaceholder,
        name: '_ProductDetailStore.reviewsArePlaceholder',
      )).value;
  Computed<List<Review>>? _$reviewsComputed;

  @override
  List<Review> get reviews => (_$reviewsComputed ??= Computed<List<Review>>(
    () => super.reviews,
    name: '_ProductDetailStore.reviews',
  )).value;
  Computed<List<String>>? _$imagesComputed;

  @override
  List<String> get images => (_$imagesComputed ??= Computed<List<String>>(
    () => super.images,
    name: '_ProductDetailStore.images',
  )).value;

  late final _$requestAtom = Atom(
    name: '_ProductDetailStore.request',
    context: context,
  );

  @override
  ObservableFuture<Product>? get request {
    _$requestAtom.reportRead();
    return super.request;
  }

  @override
  set request(ObservableFuture<Product>? value) {
    _$requestAtom.reportWrite(value, super.request, () {
      super.request = value;
    });
  }

  late final _$_ProductDetailStoreActionController = ActionController(
    name: '_ProductDetailStore',
    context: context,
  );

  @override
  void load() {
    final _$actionInfo = _$_ProductDetailStoreActionController.startAction(
      name: '_ProductDetailStore.load',
    );
    try {
      return super.load();
    } finally {
      _$_ProductDetailStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
request: ${request},
isLoading: ${isLoading},
error: ${error},
product: ${product},
display: ${display},
reviewsArePlaceholder: ${reviewsArePlaceholder},
reviews: ${reviews},
images: ${images}
    ''';
  }
}
