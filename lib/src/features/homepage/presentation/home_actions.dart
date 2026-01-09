import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/widgets/modals/scenario_picker_sheet.dart';
import '../../../../ui/widgets/modals/dissolve_dialog.dart';
import '../../breathing_exercise/presentation/breathing_confirmation_modal.dart';
import '../../breathing_exercise/presentation/breathing_exercise_screen.dart';
import '../domain/scenario_option.dart';
import 'home_dashboard_controller.dart';

Future<void> handleChangeScenarioTap(
  BuildContext context,
  WidgetRef ref,
  AsyncValue<List<ScenarioOption>> scenarioState,
) async {
  final notifier = ref.read(homeDashboardControllerProvider.notifier);
  if (scenarioState.isLoading) {
    return;
  }
  if (scenarioState.hasError) {
    await notifier.refresh();
    return;
  }
  await openScenarioPicker(context, ref);
}

Future<void> openScenarioPicker(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(homeDashboardControllerProvider.notifier);
  notifier.setPickerOpen(true);

  final selection = await ScenarioPickerSheet.show(
    context,
    scenarioOptions: ref.read(homeDashboardControllerProvider).scenarioOptions,
    onRetry: () async {
      await notifier.refresh();
      return ref.read(homeDashboardControllerProvider).scenarioOptions;
    },
  );

  notifier.setPickerOpen(false);
  if (selection != null) {
    notifier.selectScenario(selection);
  }
}

Future<void> startSpeakingFlow(BuildContext context, WidgetRef ref) async {
  final dashboardState = ref.read(homeDashboardControllerProvider);
  if (dashboardState.selectedScenario == null) {
    await openScenarioPicker(context, ref);
    if (ref.read(homeDashboardControllerProvider).selectedScenario == null) {
      return;
    }
  }

  if (!context.mounted) return;

  await showDissolveDialog(
    context: context,
    builder: (c) => BreathingConfirmationModal(
      onStart: () {
        Navigator.pop(c);
        final scenario =
            ref.read(homeDashboardControllerProvider).selectedScenario!;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BreathingExerciseScreen(
              scenario: scenario.scenarioName,
            ),
          ),
        );
      },
      onCancel: () {
        Navigator.pop(c);
      },
    ),
  );
}
