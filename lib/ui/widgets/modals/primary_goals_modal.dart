import 'package:flutter/material.dart';
import '../../../src/features/settings/domain/settings_enums.dart';
import '../chips/selectable_chip.dart';
import '../common/app_snackbar.dart';
import 'settings_modal_scaffold.dart';

class PrimaryGoalsModal extends StatefulWidget {
  final List<MainGoals> selectedGoals;

  const PrimaryGoalsModal({
    super.key,
    required this.selectedGoals,
  });

  @override
  State<PrimaryGoalsModal> createState() => _PrimaryGoalsModalState();
}

class _PrimaryGoalsModalState extends State<PrimaryGoalsModal> {
  late List<MainGoals> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<MainGoals>.from(widget.selectedGoals);
  }

  void _toggleGoal(MainGoals goal) {
    final isSelected = _selected.contains(goal);
    if (!isSelected && _selected.length >= 4) {
      showAppSnackBar(context, 'You can select up to 4 goals.');
      return;
    }
    setState(() {
      if (isSelected) {
        _selected.remove(goal);
      } else {
        _selected.add(goal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsModalScaffold(
      icon: Image.asset(
        'assets/icons/main_goals.png',
        width: 36,
        height: 36,
      ),
      title: 'Primary Goals',
      subtitle: 'What are your main goals for learning English?',
      onPrimary: _selected.isNotEmpty ? () => Navigator.pop(context, _selected) : null,
      onSecondary: () => Navigator.pop(context),
      primaryEnabled: _selected.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select at most 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7A82),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MainGoals.values.map((goal) {
              final selected = _selected.contains(goal);
              return SelectableChip(
                label: goal.label,
                selected: selected,
                onTap: () => _toggleGoal(goal),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
