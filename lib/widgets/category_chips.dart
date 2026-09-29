import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_catalog/models/category.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/shimmer_box.dart';

/// A horizontal row of category filters, starting with "All".
///
/// Tapping the chip that is already selected calls [onReselected] instead of
/// [onSelected]; the list uses it to scroll back to the top.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    required this.categories,
    required this.selectedSlug,
    required this.onSelected,
    required this.onReselected,
    super.key,
  });

  final List<Category> categories;

  /// Null means "All".
  final String? selectedSlug;
  final ValueChanged<String?> onSelected;
  final VoidCallback onReselected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        Dimens.screenPadding,
        Dimens.space4,
        Dimens.screenPadding,
        Dimens.space8,
      ),
      itemCount: categories.length + 1,
      separatorBuilder: (_, _) => const SizedBox(width: Dimens.space8),
      itemBuilder: (context, index) {
        final category = index == 0 ? null : categories[index - 1];
        final selected = category?.slug == selectedSlug;
        return FilterPill(
          label: category?.name ?? 'All',
          selected: selected,
          onTap: () {
            HapticFeedback.selectionClick();
            selected ? onReselected() : onSelected(category?.slug);
          },
        );
      },
    );
  }
}

/// A rounded filter pill: filled with the brand color when selected.
class FilterPill extends StatelessWidget {
  const FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? colors.chipSelected : colors.searchField,
            borderRadius: BorderRadius.circular(Dimens.radiusPill),
            border: Border.all(
              color: selected
                  ? colors.chipSelected
                  : colors.onHeader.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: AppText.labelMedium(
              color: selected ? colors.onChipSelected : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder pills shown while categories load.
class CategoryChipsShimmer extends StatelessWidget {
  const CategoryChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          Dimens.screenPadding,
          Dimens.space4,
          Dimens.screenPadding,
          Dimens.space8,
        ),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(width: Dimens.space8),
        itemBuilder: (_, index) => ShimmerBox(
          width: index.isEven ? 56 : 84,
          radius: Dimens.radiusPill,
        ),
      ),
    );
  }
}
