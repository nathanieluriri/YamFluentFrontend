import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'breathing_exercise_screen.dart';

class DevBreathingWrapper extends ConsumerWidget {
  const DevBreathingWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a test wrapper to endlessly show the breathing screen.
    // In a real app, this might just be a button on a dev menu.
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Dev Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BreathingExerciseScreen(scenario: 'dev_test_scenario'),
              ),
            );
          },
          child: const Text('Launch Breathing Exercise (Test)'),
        ),
      ),
    );
  }
}
