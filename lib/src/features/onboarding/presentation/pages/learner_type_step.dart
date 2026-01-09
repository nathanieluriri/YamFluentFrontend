import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/onboarding_draft.dart';
import '../../domain/onboarding_options.dart';
import '../onboarding_controller.dart';
import '../../../../../ui/widgets/cards/selectable_option_card.dart';
import '../../../../../ui/widgets/layouts/step_scaffold.dart';
import '../../../../../ui/widgets/option_definition.dart';
import '../../../../../ui/widgets/option_image.dart';

class LearnerTypeStep extends ConsumerWidget {
  final OnboardingOptions options;
  final OnboardingDraft draft;
  final VoidCallback onBack;
  final VoidCallback onProceed;

  const LearnerTypeStep({
    super.key,
    required this.options,
    required this.draft,
    required this.onBack,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learnerOptions = buildOptionDefinitions(options.learnerTypes);

    return StepScaffold(
      currentStep: 3,
      totalSteps: 5,
      title: 'Learner Type',
      subtitle: 'What type of learner are you?',
      activeIconPath: 'assets/icons/learner_type.png',
      onBack: onBack,
      proceedEnabled: draft.learnerType != null,
      onProceed: onProceed,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select level type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            for (final option in learnerOptions) ...[
              SelectableOptionCard(
                leading: OptionImage(url: option.imageUrl),
                title: option.title,
                subtitle: option.subtitle,
                selected: draft.learnerType == option.value,
                onTap: () {
                  ref.read(onboardingDraftProvider.notifier).setLearnerType(option.value);
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
