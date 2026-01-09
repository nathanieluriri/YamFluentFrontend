import 'package:flutter/material.dart';
import 'yamfluent_loader.dart';

class AppLoadingView extends StatelessWidget {
  final String message;

  const AppLoadingView({
    super.key,
    this.message = 'Hang on!',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const YamFluentLoader(),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
