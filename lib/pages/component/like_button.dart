import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final int maxLikes;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.maxLikes,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      isLiked ? Icons.favorite : Icons.favorite_border,
      color: isLiked ? Colors.red : Colors.grey,
    );
  }
}

