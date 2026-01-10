import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/onboarding_draft.dart';
import '../../domain/onboarding_options.dart';
import '../onboarding_controller.dart';
import '../../../../../ui/widgets/layouts/step_scaffold.dart';
import '../../../../../ui/widgets/daily_practice_time_slider.dart';

class DailyPracticeStep extends ConsumerStatefulWidget {
  final OnboardingOptions options;
  final OnboardingDraft draft;
  final VoidCallback onBack;
  final VoidCallback onProceed;
  final bool isSubmitting;
  final bool canProceed;

  const DailyPracticeStep({
    super.key,
    required this.options,
    required this.draft,
    required this.onBack,
    required this.onProceed,
    required this.isSubmitting,
    required this.canProceed,
  });

  @override
  ConsumerState<DailyPracticeStep> createState() => _DailyPracticeStepState();
}

class _DailyPracticeStepState extends ConsumerState<DailyPracticeStep> {
  int _sliderIndex = 0;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    final times = widget.options.dailyPracticeTimes;
    final initial = widget.draft.dailyPracticeTime;
    if (initial != null && times.isNotEmpty) {
      final index = times.indexOf(initial);
      if (index >= 0) {
        _sliderIndex = index;
        _touched = true;
      }
    } else if (times.isNotEmpty) {
      
      _sliderIndex = 0;
      _touched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(onboardingDraftProvider.notifier)
            .setDailyPracticeTime(times[0]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final times = widget.options.dailyPracticeTimes;
    final selectedText = times.isNotEmpty
        ? times[_sliderIndex]
        : 'No options available';
    final proceedEnabled = widget.canProceed;
    final canSlide = times.length > 1;

    return StepScaffold(
      currentStep: 4,
      totalSteps: 5,
      title: 'Daily Practice Schedule',
      subtitle:
          'How much time do you want to spend on daily language practice?',
      activeIconPath: 'assets/icons/daily_practice_schedule.png',
      onBack: widget.onBack,
      proceedEnabled: proceedEnabled,
      onProceed: widget.onProceed,
      isSubmitting: widget.isSubmitting,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (times.isEmpty)
              const Text(
                'No practice time options found.',
                style: TextStyle(color: Colors.white70),
              )
            else
              DailyPracticeTimeSlider(
                title: 'Daily Practice Time',
                valueText: selectedText,
                minLabel: times.isNotEmpty ? times.first : '0',
                maxLabel: times.isNotEmpty ? times.last : '0',
                value: _sliderIndex.toDouble(),
                min: 0,
                max: (times.length - 1).toDouble(),
                divisions: times.length - 1,
                onChanged: canSlide
                    ? (value) {
                        setState(() {
                          _sliderIndex = value.round();
                          _touched = true;
                        });
                        ref
                            .read(onboardingDraftProvider.notifier)
                            .setDailyPracticeTime(times[_sliderIndex]);
                      }
                    : (_) {},
              ),
            if (!_touched && widget.draft.dailyPracticeTime == null) ...[
              const SizedBox(height: 8),
              const Text(
                'Move the slider to choose a time.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
