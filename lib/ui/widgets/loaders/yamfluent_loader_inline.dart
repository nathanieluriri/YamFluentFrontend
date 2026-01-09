import 'package:flutter/material.dart';
import 'yamfluent_loader.dart';

class YamFluentLoaderInline extends StatelessWidget {
  final bool isComplete;

  const YamFluentLoaderInline({
    super.key,
    this.isComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    return YamFluentLoader(
      dotSize: 12,
      radius: 7,
      isComplete: isComplete,
    );
  }
}
