import 'package:flutter/material.dart';
import 'package:product_catalog/models/review.dart';
import 'package:product_catalog/theme/app_colors.dart';
import 'package:product_catalog/theme/app_text.dart';
import 'package:product_catalog/theme/dimens.dart';
import 'package:product_catalog/widgets/rating_stars.dart';

/// One review: initials avatar, name, date, stars and comment.
class ReviewTile extends StatelessWidget {
  const ReviewTile({required this.review, super.key});

  final Review review;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String formatDate(DateTime date) {
    final local = date.toLocal();
    return '${_months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.surfaceHighlight,
            child: Text(
              initials(review.reviewerName),
              style: AppText.labelMedium(color: colors.textSecondary),
            ),
          ),
          const SizedBox(width: Dimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.labelLarge(color: colors.text),
                      ),
                    ),
                    Text(
                      formatDate(review.date),
                      style: AppText.labelSmall(color: colors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: Dimens.space2),
                RatingStars(
                  rating: review.rating.toDouble(),
                  size: 14,
                  showValue: false,
                ),
                const SizedBox(height: Dimens.space4),
                Text(
                  review.comment,
                  style: AppText.bodyMedium(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
