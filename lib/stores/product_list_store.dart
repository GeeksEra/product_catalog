import 'dart:async';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart';
import 'package:product_catalog/models/category.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/models/product_page.dart';
import 'package:product_catalog/services/product_service.dart';

part 'product_list_store.g.dart';

/// State for the product list: paging, search and category filter.
///
/// DummyJSON cannot combine search with a category filter, so setting one
/// clears the other.
class ProductListStore = _ProductListStore with _$ProductListStore;

abstract class _ProductListStore with Store {
  _ProductListStore(
    this._service, {
    required this.pageSize,
    required this.searchDebounce,
  }) {
    paging.addPageRequestListener(_fetchPage);
  }

  final ProductService _service;
  final int pageSize;
  final Duration searchDebounce;

  /// Page keys are `skip` offsets.
  final PagingController<int, Product> paging = PagingController(
    firstPageKey: 0,
  );

  Timer? _debounce;

  /// Bumped on every reload so responses to superseded requests are dropped.
  int _generation = 0;

  /// The text in the search field. It updates on every keystroke; the fetch
  /// runs after [searchDebounce].
  @observable
  String query = '';

  @observable
  String? categorySlug;

  @observable
  ObservableFuture<List<Category>>? categories;

  /// Products matching the current search or filter, from the last page.
  @observable
  int? totalCount;

  String get _trimmedQuery => query.trim();

  @computed
  bool get isSearching => _trimmedQuery.isNotEmpty;

  @action
  void loadCategories() {
    if (categories?.status == FutureStatus.fulfilled) return;
    categories = ObservableFuture(_service.getCategories());
  }

  @action
  void setQuery(String value) {
    if (value == query) return;
    final previousQuery = _trimmedQuery;
    final hadCategory = categorySlug != null;
    query = value;
    categorySlug = null;
    _debounce?.cancel();
    // Edits that only add or remove surrounding spaces don't change the results.
    if (_trimmedQuery == previousQuery && !hadCategory) return;
    _debounce = Timer(searchDebounce, _reload);
  }

  @action
  void setCategory(String? slug) {
    if (slug == categorySlug && !isSearching) return;
    _debounce?.cancel();
    query = '';
    categorySlug = slug;
    _reload();
  }

  /// For pull to refresh. Also retries categories if they failed to load.
  Future<void> refresh() async {
    loadCategories();
    _reload();
  }

  void _reload() {
    _generation++;
    // Also runs from the debounce timer, outside an action.
    runInAction(() => totalCount = null);
    paging.refresh();
  }

  Future<void> _fetchPage(int skip) async {
    final generation = _generation;
    try {
      final page = await _loadPage(skip);
      if (generation != _generation) return;
      runInAction(() => totalCount = page.total);
      if (page.hasMore) {
        paging.appendPage(page.products, page.nextSkip);
      } else {
        paging.appendLastPage(page.products);
      }
    } on Exception catch (error) {
      if (generation != _generation) return;
      paging.error = error;
    }
  }

  Future<ProductPage> _loadPage(int skip) {
    final slug = categorySlug;
    if (isSearching) {
      return _service.searchProducts(
        _trimmedQuery,
        limit: pageSize,
        skip: skip,
      );
    }
    if (slug != null) {
      return _service.getProductsByCategory(slug, limit: pageSize, skip: skip);
    }
    return _service.getProducts(limit: pageSize, skip: skip);
  }

  void dispose() {
    _debounce?.cancel();
    paging.dispose();
  }
}
