// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductListStore on _ProductListStore, Store {
  Computed<bool>? _$isSearchingComputed;

  @override
  bool get isSearching => (_$isSearchingComputed ??= Computed<bool>(
    () => super.isSearching,
    name: '_ProductListStore.isSearching',
  )).value;

  late final _$queryAtom = Atom(
    name: '_ProductListStore.query',
    context: context,
  );

  @override
  String get query {
    _$queryAtom.reportRead();
    return super.query;
  }

  @override
  set query(String value) {
    _$queryAtom.reportWrite(value, super.query, () {
      super.query = value;
    });
  }

  late final _$categorySlugAtom = Atom(
    name: '_ProductListStore.categorySlug',
    context: context,
  );

  @override
  String? get categorySlug {
    _$categorySlugAtom.reportRead();
    return super.categorySlug;
  }

  @override
  set categorySlug(String? value) {
    _$categorySlugAtom.reportWrite(value, super.categorySlug, () {
      super.categorySlug = value;
    });
  }

  late final _$categoriesAtom = Atom(
    name: '_ProductListStore.categories',
    context: context,
  );

  @override
  ObservableFuture<List<Category>>? get categories {
    _$categoriesAtom.reportRead();
    return super.categories;
  }

  @override
  set categories(ObservableFuture<List<Category>>? value) {
    _$categoriesAtom.reportWrite(value, super.categories, () {
      super.categories = value;
    });
  }

  late final _$totalCountAtom = Atom(
    name: '_ProductListStore.totalCount',
    context: context,
  );

  @override
  int? get totalCount {
    _$totalCountAtom.reportRead();
    return super.totalCount;
  }

  @override
  set totalCount(int? value) {
    _$totalCountAtom.reportWrite(value, super.totalCount, () {
      super.totalCount = value;
    });
  }

  late final _$_ProductListStoreActionController = ActionController(
    name: '_ProductListStore',
    context: context,
  );

  @override
  void loadCategories() {
    final _$actionInfo = _$_ProductListStoreActionController.startAction(
      name: '_ProductListStore.loadCategories',
    );
    try {
      return super.loadCategories();
    } finally {
      _$_ProductListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setQuery(String value) {
    final _$actionInfo = _$_ProductListStoreActionController.startAction(
      name: '_ProductListStore.setQuery',
    );
    try {
      return super.setQuery(value);
    } finally {
      _$_ProductListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCategory(String? slug) {
    final _$actionInfo = _$_ProductListStoreActionController.startAction(
      name: '_ProductListStore.setCategory',
    );
    try {
      return super.setCategory(slug);
    } finally {
      _$_ProductListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
query: ${query},
categorySlug: ${categorySlug},
categories: ${categories},
totalCount: ${totalCount},
isSearching: ${isSearching}
    ''';
  }
}
