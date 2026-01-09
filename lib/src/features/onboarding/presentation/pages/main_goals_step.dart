import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/onboarding_draft.dart';
import '../../domain/onboarding_options.dart';
import '../onboarding_controller.dart';
import '../../../../../ui/widgets/chips/selectable_chip.dart';
import '../../../../../ui/widgets/layouts/step_scaffold.dart';
import '../../../../../ui/widgets/common/app_snackbar.dart';

class MainGoalsStep extends ConsumerWidget {
  final OnboardingOptions options;
  final OnboardingDraft draft;
  final VoidCallback onBack;
  final VoidCallback onProceed;

  const MainGoalsStep({
    super.key,
    required this.options,
    required this.draft,
    required this.onBack,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StepScaffold(
      currentStep: 2,
      totalSteps: 5,
      title: 'Main Goals',
      subtitle: 'What are your main goals for learning English?',
      activeIconPath: 'assets/icons/main_goals.png',
      onBack: onBack,
      proceedEnabled: draft.mainGoals.isNotEmpty,
      onProceed: onProceed,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select at most 4',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options.mainGoals.map((goal) {
                final selected = draft.mainGoals.contains(goal);
                return SelectableChip(
                  label: goal,
                  selected: selected,
                  onTap: () {
                    if (!selected && draft.mainGoals.length >= 4) {
                      showAppSnackBar(context, 'You can select up to 4 goals.');
                      return;
                    }
                    ref.read(onboardingDraftProvider.notifier).toggleGoal(goal);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
