import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/frosted_surface.dart';

/// One destination in [AppTabBar].
class AppTab {
  const AppTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// A frosted bottom tab bar. Content scrolls underneath it.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppTab> tabs;
  final int currentIndex;

  /// Called for every tap, including on the current tab, so the shell can
  /// pop to the tab's root or scroll it to the top.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return FrostedSurface(
      dividerEdge: VerticalDirection.up,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: Dimens.tabBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _TabItem(
                    tab: tabs[i],
                    selected: i == currentIndex,
                    index: i,
                    count: tabs.length,
                    colors: colors,
                    onTap: () {
                      if (i != currentIndex) HapticFeedback.selectionClick();
                      onTap(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.index,
    required this.count,
    required this.colors,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final int index;
  final int count;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? colors.text : colors.textTertiary;
    return Semantics(
      button: true,
      selected: selected,
      label: '${tab.label}, tab ${index + 1} of $count',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        radius: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // A brand-yellow pill behind the active icon.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: selected
                    ? colors.brand
                    : colors.brand.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(Dimens.radiusPill),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  selected ? tab.selectedIcon : tab.icon,
                  key: ValueKey(selected),
                  color: selected ? colors.onBrand : color,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: Dimens.space2),
            Text(
              tab.label,
              style: AppText.labelSmall(
                color: color,
              ).copyWith(fontWeight: selected ? AppText.semiBold : null),
            ),
          ],
        ),
      ),
    );
  }
}
