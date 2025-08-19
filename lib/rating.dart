import 'package:flutter/material.dart';

class Rating extends StatelessWidget {
  final int totalRating;
  final int rating;
  final void Function(int)? onRatingChange;
  const Rating({
    super.key,
    required this.rating,
    this.onRatingChange,
    this.totalRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < totalRating; i++)
          IconButton(
            onPressed: () => onRatingChange?.call(i + 1),
            icon: Icon(
              i < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          ),
      ],
    );
  }
}
