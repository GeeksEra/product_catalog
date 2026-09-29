import 'package:flutter/material.dart';
import 'package:product_catalog/services/api_exception.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';

/// A user-facing message for any error that reaches the UI.
String describeError(Object? error) => switch (error) {
  ApiException(:final message) => message,
  _ => 'Something went wrong. Please try again.',
};

/// A failure message with a Retry button.
///
/// The default form fills the available space. [ErrorView.inline] is a single
/// row, used below a list when a later page fails.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, required this.onRetry, super.key})
    : inline = false;

  const ErrorView.inline({
    required this.error,
    required this.onRetry,
    super.key,
  }) : inline = true;

  final Object? error;
  final VoidCallback onRetry;
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final message = describeError(error);

    if (inline) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimens.space8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: AppText.bodySmall(color: colors.textSecondary),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: Dimens.iconLarge,
              color: colors.textTertiary,
            ),
            const SizedBox(height: Dimens.space16),
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: AppText.headingSmall(color: colors.text),
            ),
            const SizedBox(height: Dimens.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.bodyMedium(color: colors.textSecondary),
            ),
            const SizedBox(height: Dimens.space24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
