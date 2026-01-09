import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/onboarding_draft.dart';
import '../../domain/onboarding_options.dart';
import '../onboarding_controller.dart';
import '../../../../../ui/widgets/cards/selectable_option_card.dart';
import '../../../../../ui/widgets/layouts/step_scaffold.dart';
import '../../../../../ui/widgets/option_definition.dart';
import '../../../../../ui/widgets/option_image.dart';

class CurrentProficiencyStep extends ConsumerWidget {
  final OnboardingOptions options;
  final OnboardingDraft draft;
  final VoidCallback onBack;
  final VoidCallback onProceed;

  const CurrentProficiencyStep({
    super.key,
    required this.options,
    required this.draft,
    required this.onBack,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proficiencyOptions = buildOptionDefinitions(options.currentProficiencies);

    return StepScaffold(
      currentStep: 1,
      totalSteps: 5,
      title: 'Current Proficiency',
      subtitle: 'What is your current proficiency in English?',
      activeIconPath: 'assets/icons/current_proficiency.png',
      onBack: onBack,
      proceedEnabled: draft.currentProficiency != null,
      onProceed: onProceed,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Proficiency level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            for (final option in proficiencyOptions) ...[
              SelectableOptionCard(
                leading: OptionImage(url: option.imageUrl),
                title: option.title,
                subtitle: option.subtitle,
                selected: draft.currentProficiency == option.value,
                onTap: () {
                  ref.read(onboardingDraftProvider.notifier).setCurrentProficiency(option.value);
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
