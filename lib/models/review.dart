import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

/// A customer review as returned inside a product's `reviews` array.
@JsonSerializable()
class Review {
  const Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  final int rating;
  final String comment;
  final DateTime date;
  final String reviewerName;
}
