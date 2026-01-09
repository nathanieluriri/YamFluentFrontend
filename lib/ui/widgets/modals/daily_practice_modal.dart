import 'package:flutter/material.dart';
import '../../../src/features/settings/domain/settings_enums.dart';
import '../daily_practice_time_slider.dart';
import 'settings_modal_scaffold.dart';

class DailyPracticeModal extends StatefulWidget {
  final DailyPracticeTime? selectedTime;

  const DailyPracticeModal({
    super.key,
    this.selectedTime,
  });

  @override
  State<DailyPracticeModal> createState() => _DailyPracticeModalState();
}

class _DailyPracticeModalState extends State<DailyPracticeModal> {
  int _sliderIndex = 0;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    final times = DailyPracticeTime.values;
    final initial = widget.selectedTime;
    if (initial != null && times.isNotEmpty) {
      final index = times.indexOf(initial);
      if (index >= 0) {
        _sliderIndex = index;
        _touched = true;
      }
    } else if (times.length == 1) {
      _sliderIndex = 0;
      _touched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final times = DailyPracticeTime.values;
    final hasOptions = times.isNotEmpty;
    final selectedText = hasOptions ? times[_sliderIndex].label : 'No options';
    final canSave = hasOptions && _touched;
    final canSlide = times.length > 1;

    return SettingsModalScaffold(
      icon: Image.asset(
        'assets/icons/daily_practice_schedule.png',
        width: 36,
        height: 36,
      ),
      title: 'Daily Practice Schedule',
      subtitle: 'How much time do you want to spend on daily language practice?',
      onPrimary: canSave ? () => Navigator.pop(context, times[_sliderIndex]) : null,
      onSecondary: () => Navigator.pop(context),
      primaryEnabled: canSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasOptions)
            const Text(
              'No practice time options found.',
              style: TextStyle(color: Color(0xFF6B7A82)),
            )
          else
            DailyPracticeTimeSlider(
              title: 'Daily Practice Time',
              valueText: selectedText,
              minLabel: times.first.label,
              maxLabel: times.last.label,
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
                    }
                  : (_) {},
            ),
          if (!canSave && hasOptions) ...[
            const SizedBox(height: 8),
            const Text(
              'Move the slider to choose a time.',
              style: TextStyle(color: Color(0xFF6B7A82), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
