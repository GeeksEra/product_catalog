import 'package:product_catalog/models/review.dart';

/// Simulated reviews, shown only when the API returns none for a product.
///
/// The brief asks for mocked reviews. DummyJSON already returns real ones for
/// most products, so this is a fallback rather than the main source.
final List<Review> placeholderReviews = [
  Review(
    rating: 5,
    comment: 'Exactly as described and it arrived quickly. Would buy again.',
    date: DateTime.utc(2025, 3, 12),
    reviewerName: 'Alex Morgan',
  ),
  Review(
    rating: 4,
    comment: 'Good quality for the price. The packaging could be better.',
    date: DateTime.utc(2025, 2, 27),
    reviewerName: 'Priya Shah',
  ),
  Review(
    rating: 3,
    comment: 'Does the job, but it took a while to get used to.',
    date: DateTime.utc(2025, 1, 9),
    reviewerName: 'Jordan Lee',
  ),
];
