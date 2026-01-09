import 'package:flutter/material.dart';
import 'app_loading_view.dart';

class YamFluentLoaderOverlay extends StatelessWidget {
  final bool dismissible;
  final Color barrierColor;
  final Widget? child;

  const YamFluentLoaderOverlay({
    super.key,
    this.dismissible = false,
    this.barrierColor = const Color(0x22000000),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        Positioned.fill(
          child: dismissible
              ? GestureDetector(
                  onTap: () {},
                  child: Container(color: barrierColor),
                )
              : ModalBarrier(
                  dismissible: false,
                  color: barrierColor,
                ),
        ),
        const Positioned.fill(child: AppLoadingView()),
      ],
    );
  }
}
