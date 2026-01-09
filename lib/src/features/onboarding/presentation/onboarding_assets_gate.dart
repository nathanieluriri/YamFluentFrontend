import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'loading_screen.dart';
import 'onboarding_warmup_provider.dart';

class OnboardingAssetsGate extends ConsumerStatefulWidget {
  final List<String> requiredImageUrls;
  final Widget child;

  const OnboardingAssetsGate({
    super.key,
    required this.requiredImageUrls,
    required this.child,
  });

  @override
  ConsumerState<OnboardingAssetsGate> createState() => _OnboardingAssetsGateState();
}

class _OnboardingAssetsGateState extends ConsumerState<OnboardingAssetsGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareAssets();
    });
  }

  Future<void> _prepareAssets() async {
    if (_ready) return;
    await ref.read(onboardingWarmupProvider.future);
    if (!mounted) return;
    await precacheOnboardingImages(context, widget.requiredImageUrls);
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return widget.child;
    }

    final warmAssets = ref.watch(onboardingWarmupProvider).valueOrNull;
    return LoadingScreen(
      enableTimer: false,
      showCta: false,
      controller: warmAssets?.earthVideo,
    );
  }
}
