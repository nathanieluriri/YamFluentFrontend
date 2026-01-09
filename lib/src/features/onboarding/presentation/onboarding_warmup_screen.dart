import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'loading_screen.dart';
import 'onboarding_warmup_provider.dart';

class OnboardingWarmupScreen extends ConsumerStatefulWidget {
  const OnboardingWarmupScreen({super.key});

  @override
  ConsumerState<OnboardingWarmupScreen> createState() => _OnboardingWarmupScreenState();
}

class _OnboardingWarmupScreenState extends ConsumerState<OnboardingWarmupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmup();
    });
  }

  Future<void> _warmup() async {
    try {
      final warmAssets = await ref.read(onboardingWarmupProvider.future);
      if (!mounted) return;
      await precacheOnboardingImages(context, warmAssets.prefetchedImageUrls);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Onboarding warmup failed: $e');
      }
    }
    if (mounted) {
      context.goNamed('onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final warmAssets = ref.watch(onboardingWarmupProvider).valueOrNull;
    return LoadingScreen(
      enableTimer: false,
      showCta: false,
      controller: warmAssets?.earthVideo,
    );
  }
}
