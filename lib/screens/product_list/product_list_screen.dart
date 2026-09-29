import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mobx/mobx.dart' show FutureStatus;
import 'package:product_catalog/config/service_locator.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/screens/product_detail/product_detail_screen.dart';
import 'package:product_catalog/stores/product_list_store.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/category_chips.dart';
import 'package:product_catalog/widgets/empty_view.dart';
import 'package:product_catalog/widgets/error_view.dart';
import 'package:product_catalog/widgets/fade_in_item.dart';
import 'package:product_catalog/widgets/large_title_header.dart';
import 'package:product_catalog/widgets/product_card.dart';
import 'package:product_catalog/widgets/product_card_shimmer.dart';
import 'package:product_catalog/widgets/product_search_bar.dart';

/// The paginated product list, with search and a category filter.
///
/// The header behaves like an iOS large-title screen with a search
/// controller: scrolling hides the search field, then folds the title; focusing
/// the search field slides the title away and pins the field at the top.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({this.scrollToTop, super.key});

  /// Fires when the user re-taps this screen's tab.
  final Listenable? scrollToTop;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  final ProductListStore _store = getIt<ProductListStore>()..loadCategories();
  final ScrollController _scroll = ScrollController();
  final FocusNode _searchFocus = FocusNode();
  late final AnimationController _searchAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final CurvedAnimation _searchCurve = CurvedAnimation(
    parent: _searchAnimation,
    curve: Curves.easeInOutCubic,
  );

  /// True from focusing the field until Cancel. Dragging the list hides the
  /// keyboard but keeps search active, as on iOS.
  bool _searchActive = false;

  /// Products whose fade-in has already played.
  final Set<int> _revealed = {};

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onSearchFocusChanged);
    widget.scrollToTop?.addListener(_scrollToTop);
  }

  @override
  void didUpdateWidget(ProductListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollToTop != widget.scrollToTop) {
      oldWidget.scrollToTop?.removeListener(_scrollToTop);
      widget.scrollToTop?.addListener(_scrollToTop);
    }
  }

  @override
  void dispose() {
    widget.scrollToTop?.removeListener(_scrollToTop);
    _searchFocus.dispose();
    _searchCurve.dispose();
    _searchAnimation.dispose();
    _scroll.dispose();
    _store.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (!_searchFocus.hasFocus || _searchActive) return;
    setState(() => _searchActive = true);
    // Start from the top so the pinned field sits right above the results.
    if (_scroll.hasClients && _scroll.offset > 0) _scroll.jumpTo(0);
    unawaited(_searchAnimation.forward());
  }

  void _cancelSearch() {
    _searchFocus.unfocus();
    _store.setQuery('');
    setState(() => _searchActive = false);
    unawaited(_searchAnimation.reverse());
  }

  void _scrollToTop() {
    if (!_scroll.hasClients || _scroll.offset <= 0) return;
    // From far down the list, jump most of the way first so the animation
    // stays short and doesn't build every card in between.
    const nearTop = 1600.0;
    if (_scroll.offset > nearTop) _scroll.jumpTo(nearTop);
    unawaited(
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _selectCategory(String? slug) {
    _store.setCategory(slug);
    if (_scroll.hasClients && _scroll.offset > 0) _scroll.jumpTo(0);
  }

  /// Settles a half-hidden search field or title, like UIKit does.
  bool _onScrollEnd(ScrollEndNotification notification) {
    if (notification.depth != 0 || !_scroll.hasClients) return false;
    final progress = _searchCurve.value;
    final searchEnd = LargeTitleHeader.searchCollapseExtent(
      hasSearch: true,
      searchProgress: progress,
    );
    final titleEnd = LargeTitleHeader.collapseExtent(
      hasSearch: true,
      searchProgress: progress,
      compact: LargeTitleHeader.isCompact(context),
    );
    final offset = _scroll.offset;
    double? target;
    if (offset > 0 && offset < searchEnd) {
      target = offset < searchEnd / 2 ? 0 : searchEnd;
    } else if (offset > searchEnd && offset < titleEnd) {
      target = offset < (searchEnd + titleEnd) / 2 ? searchEnd : titleEnd;
    }
    if (target != null) {
      final destination = target;
      Future.microtask(
        () => _scroll.animateTo(
          destination,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        ),
      );
    }
    return false;
  }

  Future<void> _refresh() async {
    try {
      await _store.refresh();
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  static int _columnsFor(double width) {
    if (width >= 960) return 3;
    if (width >= Dimens.gridBreakpoint) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final media = MediaQuery.of(context);

    return PopScope(
      canPop: !_searchActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _searchActive) _cancelSearch();
      },
      // Material, not Scaffold: snack bars then show once, on the app shell's
      // Scaffold above the tab bar, instead of also behind it.
      child: Material(
        color: context.colors.background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = _columnsFor(constraints.maxWidth);
            final list = AnimatedBuilder(
              animation: _searchCurve,
              builder: (context, _) =>
                  NotificationListener<ScrollEndNotification>(
                    onNotification: _onScrollEnd,
                    child: CustomScrollView(
                      controller: _scroll,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: isIOS
                          ? const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            )
                          : const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        Observer(
                          builder: (_) => LargeTitleHeader(
                            title: 'Products',
                            searchProgress: _searchCurve.value,
                            search: ProductSearchBar(
                              query: _store.query,
                              onChanged: _store.setQuery,
                              focusNode: _searchFocus,
                              showCancel: _searchActive,
                              onCancel: _cancelSearch,
                            ),
                            bottom: _buildCategories(),
                          ),
                        ),
                        if (isIOS)
                          CupertinoSliverRefreshControl(onRefresh: _refresh),
                        Observer(builder: (_) => _buildResultCount()),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            Dimens.screenPadding,
                            Dimens.space4,
                            Dimens.screenPadding,
                            media.padding.bottom + Dimens.space24,
                          ),
                          sliver: _buildProducts(columns),
                        ),
                      ],
                    ),
                  ),
            );

            if (isIOS) return list;
            return RefreshIndicator(
              onRefresh: _refresh,
              edgeOffset:
                  media.padding.top +
                  Dimens.navBarHeight +
                  Dimens.chipRowHeight,
              child: list,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final future = _store.categories;
    return switch (future?.status) {
      FutureStatus.fulfilled => CategoryChips(
        categories: future!.value!,
        selectedSlug: _store.categorySlug,
        onSelected: _selectCategory,
        onReselected: _scrollToTop,
      ),
      FutureStatus.rejected => Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimens.screenPadding,
          Dimens.space4,
          Dimens.screenPadding,
          Dimens.space8,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FilterPill(
            label: 'Categories unavailable · Retry',
            selected: false,
            onTap: _store.loadCategories,
          ),
        ),
      ),
      _ => const CategoryChipsShimmer(),
    };
  }

  /// "23 results" under the header while searching or filtering.
  Widget _buildResultCount() {
    final total = _store.totalCount;
    final filtered = _store.isSearching || _store.categorySlug != null;
    final visible = filtered && total != null && total > 0;
    return SliverToBoxAdapter(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: visible
            ? Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimens.screenPadding,
                  Dimens.space8,
                  Dimens.screenPadding,
                  Dimens.space4,
                ),
                child: Text(
                  total == 1 ? '1 result' : '$total results',
                  style: AppText.labelMedium(
                    color: context.colors.textTertiary,
                  ),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }

  Widget _buildProducts(int columns) {
    final delegate = PagedChildBuilderDelegate<Product>(
      animateTransitions: true,
      itemBuilder: (context, product, index) => FadeInItem(
        key: ValueKey(product.id),
        index: index,
        animate: _revealed.add(product.id),
        child: ProductCard(
          product: product,
          onTap: () => _openProduct(product),
        ),
      ),
      firstPageProgressIndicatorBuilder: (_) => Padding(
        padding: const EdgeInsets.only(top: Dimens.space8),
        child: ProductListShimmer(columns: columns),
      ),
      // Skeleton cards at the end of the list while the next page loads.
      newPageProgressIndicatorBuilder: (_) => Padding(
        padding: const EdgeInsets.only(top: Dimens.space12),
        child: ProductListShimmer(
          count: columns == 1 ? 2 : columns,
          columns: columns,
        ),
      ),
      firstPageErrorIndicatorBuilder: (_) =>
          ErrorView(error: _store.paging.error, onRetry: _store.paging.refresh),
      newPageErrorIndicatorBuilder: (_) => ErrorView.inline(
        error: _store.paging.error,
        onRetry: _store.paging.retryLastFailedRequest,
      ),
      noItemsFoundIndicatorBuilder: (_) => Observer(
        builder: (_) => EmptyView(
          title: 'No products found',
          message: _store.isSearching
              ? 'Nothing matches "${_store.query.trim()}". '
                    'Try another search.'
              : 'There are no products here yet.',
        ),
      ),
      noMoreItemsIndicatorBuilder: (_) =>
          Observer(builder: (_) => _EndOfList(total: _store.totalCount)),
    );

    if (columns == 1) {
      return PagedSliverList<int, Product>.separated(
        pagingController: _store.paging,
        builderDelegate: delegate,
        separatorBuilder: (_, _) => const SizedBox(height: Dimens.space12),
      );
    }
    return PagedSliverAlignedGrid<int, Product>.count(
      pagingController: _store.paging,
      builderDelegate: delegate,
      crossAxisCount: columns,
      mainAxisSpacing: Dimens.space12,
      crossAxisSpacing: Dimens.space12,
      showNewPageProgressIndicatorAsGridChild: false,
      showNewPageErrorIndicatorAsGridChild: false,
      showNoMoreItemsIndicatorAsGridChild: false,
    );
  }
}

class _EndOfList extends StatelessWidget {
  const _EndOfList({required this.total});

  final int? total;

  @override
  Widget build(BuildContext context) {
    final count = total;
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.space24),
      child: Center(
        child: Text(switch (count) {
          null => "You're all caught up",
          1 => "That's the only product",
          _ => "That's all $count products",
        }, style: AppText.labelMedium(color: context.colors.textTertiary)),
      ),
    );
  }
}
