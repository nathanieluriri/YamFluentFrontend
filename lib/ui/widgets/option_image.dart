import 'package:flutter/material.dart';
import 'common/shimmer_box.dart';

class OptionImage extends StatelessWidget {
  final String url;

  const OptionImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 20,
        color: Colors.black45,
      );
    }
    return Image.network(
      url,
      height: 40,
      width: 40,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const ShimmerBox(height: 20, width: 20, borderRadius: 10);
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.image_not_supported,
          size: 20,
          color: Colors.black45,
        );
      },
    );
  }
}
