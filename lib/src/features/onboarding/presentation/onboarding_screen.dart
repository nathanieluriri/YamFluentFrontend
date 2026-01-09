import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/onboarding_options.dart';
import 'onboarding_controller.dart';
import '../../../../ui/widgets/loaders/app_loading_view.dart';
import 'pages/current_proficiency_step.dart';
import 'pages/daily_practice_step.dart';
import 'pages/learner_type_step.dart';
import 'pages/main_goals_step.dart';
import 'pages/native_language_step.dart';
import 'onboarding_assets_gate.dart';
import '../../../../ui/widgets/common/app_snackbar.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsState = ref.watch(onboardingOptionsProvider);

    return optionsState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: AppLoadingView(),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unable to load onboarding options.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(onboardingOptionsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (options) => _OnboardingFlow(options: options),
    );
  }
}

class _OnboardingFlow extends ConsumerStatefulWidget {
  final OnboardingOptions options;

  const _OnboardingFlow({required this.options});

  @override
  ConsumerState<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<_OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    setState(() => _currentStep = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _handleBack() {
    if (_currentStep == 0) {
      context.pop();
      return;
    }
    _goToStep(_currentStep - 1);
  }

  void _handleNext() {
    if (_currentStep < 4) {
      _goToStep(_currentStep + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingDraftProvider);
    final submitState = ref.watch(onboardingSubmitProvider);

    ref.listen(onboardingSubmitProvider, (previous, next) async {
      final submitController = ref.read(onboardingSubmitProvider.notifier);
      if (submitController.hasSubmitted &&
          previous?.isLoading == true &&
          next.hasValue &&
          !next.isLoading) {
        submitController.resetSubmissionFlag();
        submitController.resetSubmissionFlag();
        // Navigate to loading screen to simulate personalization
        if (mounted) {
          context.goNamed(
            'loading',
            queryParameters: {'from_onboarding': '1'},
          );
        }
      } else if (submitController.hasSubmitted && next.hasError) {
        submitController.resetSubmissionFlag();
        showAppSnackBar(
          context,
          'Failed to finish onboarding: ${formatSnackBarError(next.error)}',
        );
      }
    });

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        OnboardingAssetsGate(
          requiredImageUrls: const [],
          child: NativeLanguageStep(
            options: widget.options,
            draft: draft,
            onBack: null,
            onProceed: _handleNext,
          ),
        ),
        OnboardingAssetsGate(
          requiredImageUrls: widget.options.currentProficiencies
              .map((item) => item.imageUrl)
              .where((url) => url.trim().isNotEmpty)
              .toList(),
          child: CurrentProficiencyStep(
            options: widget.options,
            draft: draft,
            onBack: _handleBack,
            onProceed: _handleNext,
          ),
        ),
        MainGoalsStep(
          options: widget.options,
          draft: draft,
          onBack: _handleBack,
          onProceed: _handleNext,
        ),
        OnboardingAssetsGate(
          requiredImageUrls: widget.options.learnerTypes
              .map((item) => item.imageUrl)
              .where((url) => url.trim().isNotEmpty)
              .toList(),
          child: LearnerTypeStep(
            options: widget.options,
            draft: draft,
            onBack: _handleBack,
            onProceed: _handleNext,
          ),
        ),
        DailyPracticeStep(
          options: widget.options,
          draft: draft,
          onBack: _handleBack,
          onProceed: () async {
            if (draft.isComplete) {
              await ref.read(onboardingSubmitProvider.notifier).submit(draft);
            }
          },
          isSubmitting: submitState.isLoading,
          canProceed: draft.isComplete,
        ),
      ],
    );
  }
}
