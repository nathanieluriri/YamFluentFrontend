import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';
import '../layouts/background_layout.dart';
import '../progress/step_progress_indicator.dart';
import '../loaders/yamfluent_loader_inline.dart';

class StepScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onProceed;
  final String proceedLabel;
  final bool proceedEnabled;
  final bool isSubmitting;
  final String activeIconPath;
  final String backIconPath;

  const StepScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.activeIconPath,
    this.onBack,
    this.onProceed,
    this.proceedLabel = 'Proceed',
    this.proceedEnabled = true,
    this.isSubmitting = false,
    this.backIconPath = 'assets/icons/back.png',
  });

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundLayout(
      topOffset: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                onBack == null
                    ? const SizedBox(height: 36, width: 36)
                    : _BackButton(
                        onBack: onBack,
                        iconPath: backIconPath,
                      ),
                StepProgressIndicator(
                  currentIndex: currentStep,
                  total: totalSteps,
                  activeIconPath: activeIconPath,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(child: child),
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              scale: proceedEnabled && !isSubmitting ? 1.0 : 0.98,
              child: PrimaryButton(
                onPressed: proceedEnabled && !isSubmitting ? onProceed : null,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation.drive(
                          Tween<double>(begin: 0.98, end: 1.0),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: isSubmitting
                      ? const YamFluentLoaderInline(
                          key: ValueKey('loader'),
                        )
                      : Text(
                          proceedLabel,
                          key: const ValueKey('label'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onBack;
  final String iconPath;

  const _BackButton({
    this.onBack,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onBack,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        width: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Image.asset(iconPath),
      ),
    );
  }
}
