import 'package:flutter/cupertino.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';

/// The iOS-style search field above the product list.
///
/// [query] is the store's current value; when the store clears it (a category
/// was picked, for example), the field clears too. [showCancel] slides in a
/// Cancel button, which the screen shows while search is active.
class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({
    required this.query,
    required this.onChanged,
    required this.focusNode,
    required this.showCancel,
    required this.onCancel,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final bool showCancel;
  final VoidCallback onCancel;

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(ProductSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: Dimens.searchFieldHeight,
            child: CupertinoSearchTextField(
              controller: _controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              onSuffixTap: () {
                _controller.clear();
                widget.onChanged('');
              },
              placeholder: 'Search products',
              style: AppText.bodyMedium(color: colors.text),
              placeholderStyle: AppText.bodyMedium(color: colors.textTertiary),
              itemColor: colors.textTertiary,
              backgroundColor: colors.searchField,
              borderRadius: BorderRadius.circular(Dimens.radiusMedium - 2),
              cursorColor: colors.primary,
              prefixInsets: const EdgeInsetsDirectional.fromSTEB(10, 0, 4, 2),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: widget.showCancel
              ? CupertinoButton(
                  padding: const EdgeInsets.only(left: Dimens.space12),
                  minimumSize: const Size(Dimens.minTapTarget, 0),
                  onPressed: widget.onCancel,
                  child: Text(
                    'Cancel',
                    style: AppText.labelLarge(
                      color: colors.onHeader,
                    ).copyWith(fontSize: 16),
                  ),
                )
              : const SizedBox(height: Dimens.searchFieldHeight),
        ),
      ],
    );
  }
}
