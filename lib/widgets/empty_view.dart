import 'package:flutter/material.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';

/// Shown when a request succeeds but returns nothing.
class EmptyView extends StatelessWidget {
  const EmptyView({required this.title, required this.message, super.key});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: Dimens.iconLarge,
              color: colors.textTertiary,
            ),
            const SizedBox(height: Dimens.space16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.headingSmall(color: colors.text),
            ),
            const SizedBox(height: Dimens.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.bodyMedium(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
