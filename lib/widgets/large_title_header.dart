import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/frosted_surface.dart';

/// An iOS-style pinned header: compact bar, large title, optional search row
/// and optional pinned [bottom] row (the filter chips).
///
/// Scrolling up first hides the search row, then folds the large title into
/// the compact bar, as `UISearchController` does with
/// `hidesSearchBarWhenScrolling`. While [searchProgress] runs from 0 to 1
/// (the search field gaining focus), the compact bar and large title slide
/// away and the search row pins itself to the top.
///
/// On short screens (a phone in landscape) there is no large title: the title
/// sits in the compact bar, as UIKit does, so the list keeps its room.
class LargeTitleHeader extends StatelessWidget {
  const LargeTitleHeader({
    required this.title,
    this.search,
    this.searchProgress = 0,
    this.bottom,
    super.key,
  });

  final String title;

  /// The search row content, usually a search field and a Cancel button.
  final Widget? search;

  /// 0 when search is idle, 1 when it is active. Animate it for the
  /// transition.
  final double searchProgress;

  /// Stays pinned below the bar, [Dimens.chipRowHeight] tall.
  final Widget? bottom;

  /// Whether the screen is too short for a large title.
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 500;

  /// How far the list can scroll before the search row is fully hidden. Used
  /// by screens to snap a half-hidden header.
  static double searchCollapseExtent({
    required bool hasSearch,
    required double searchProgress,
  }) {
    return hasSearch ? Dimens.searchRowHeight * (1 - searchProgress) : 0;
  }

  /// Scroll offset at which the large title has fully folded away.
  static double collapseExtent({
    required bool hasSearch,
    required double searchProgress,
    required bool compact,
  }) {
    final title = compact ? 0 : Dimens.largeTitleHeight * (1 - searchProgress);
    return searchCollapseExtent(
          hasSearch: hasSearch,
          searchProgress: searchProgress,
        ) +
        title;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _LargeTitleDelegate(
        title: title,
        search: search,
        searchProgress: searchProgress.clamp(0, 1),
        bottom: bottom,
        topInset: MediaQuery.paddingOf(context).top,
        compact: isCompact(context),
        colors: context.colors,
      ),
    );
  }
}

class _LargeTitleDelegate extends SliverPersistentHeaderDelegate {
  _LargeTitleDelegate({
    required this.title,
    required this.search,
    required this.searchProgress,
    required this.bottom,
    required this.topInset,
    required this.compact,
    required this.colors,
  });

  final String title;
  final Widget? search;
  final double searchProgress;
  final Widget? bottom;
  final double topInset;
  final bool compact;
  final AppColors colors;

  double get _p => searchProgress;
  double get _navHeight => Dimens.navBarHeight * (1 - _p);
  double get _titleHeight => compact ? 0 : Dimens.largeTitleHeight * (1 - _p);
  double get _searchHeight => search == null ? 0 : Dimens.searchRowHeight;
  double get _bottomHeight => bottom == null ? 0 : Dimens.chipRowHeight;

  /// While search is active the search row can't scroll away.
  double get _pinnedSearch => _searchHeight * _p;

  @override
  double get maxExtent =>
      topInset + _navHeight + _titleHeight + _searchHeight + _bottomHeight;

  @override
  double get minExtent => topInset + _navHeight + _pinnedSearch + _bottomHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final collapsibleSearch = _searchHeight - _pinnedSearch;
    final searchShrink = math.min(shrinkOffset, collapsibleSearch);
    final titleShrink = math.min(shrinkOffset - searchShrink, _titleHeight);

    final searchHeight = _searchHeight - searchShrink;
    final titleHeight = _titleHeight - titleShrink;

    // The search row fades out a little before it is gone, like UIKit.
    final searchOpacity = _searchHeight == 0
        ? 0.0
        : ((searchHeight - 16) / (_searchHeight - 16)).clamp(0.0, 1.0);
    final titleFraction = _titleHeight == 0 ? 1.0 : titleShrink / _titleHeight;
    final compactTitleOpacity = ((titleFraction - 0.7) / 0.3).clamp(0.0, 1.0);
    final collapsed = shrinkOffset >= maxExtent - minExtent - 0.5;

    return FrostedSurface(
      color: colors.header,
      showDivider: collapsed || overlaps,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topInset),
          SizedBox(
            height: _navHeight,
            child: ClipRect(
              child: Opacity(
                opacity: 1 - _p,
                child: _CompactBar(
                  title: title,
                  titleOpacity: compactTitleOpacity,
                ),
              ),
            ),
          ),
          SizedBox(
            height: titleHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.bottomLeft,
                minHeight: Dimens.largeTitleHeight,
                maxHeight: Dimens.largeTitleHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimens.screenPadding,
                    0,
                    Dimens.screenPadding,
                    Dimens.space4,
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.largeTitle(color: colors.onHeader),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (search != null)
            SizedBox(
              height: searchHeight,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.bottomCenter,
                  minHeight: Dimens.searchRowHeight,
                  maxHeight: Dimens.searchRowHeight,
                  child: Opacity(
                    opacity: searchOpacity,
                    child: IgnorePointer(
                      ignoring: searchOpacity < 0.5,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          Dimens.screenPadding,
                          // Once pinned, the row sits under the status bar.
                          Dimens.space4 + Dimens.space4 * _p,
                          Dimens.screenPadding,
                          Dimens.space12 - Dimens.space4 * _p,
                        ),
                        child: search,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (bottom != null) SizedBox(height: _bottomHeight, child: bottom),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_LargeTitleDelegate old) {
    return old.title != title ||
        old.search != search ||
        old.searchProgress != searchProgress ||
        old.bottom != bottom ||
        old.topInset != topInset ||
        old.compact != compact ||
        old.colors != colors;
  }
}

class _CompactBar extends StatelessWidget {
  const _CompactBar({required this.title, required this.titleOpacity});

  final String title;
  final double titleOpacity;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.bottomCenter,
      minHeight: Dimens.navBarHeight,
      maxHeight: Dimens.navBarHeight,
      child: Center(
        child: ExcludeSemantics(
          excluding: titleOpacity < 0.5,
          child: Opacity(
            opacity: titleOpacity,
            child: Text(
              title,
              style: AppText.navTitle(color: context.colors.onHeader),
            ),
          ),
        ),
      ),
    );
  }
}
