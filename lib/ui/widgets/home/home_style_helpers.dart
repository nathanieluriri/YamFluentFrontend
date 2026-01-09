import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/core/utils/failure.dart';
import '../../../src/features/homepage/domain/scenario_option.dart';

Color difficultyColor(int rating) {
  switch (rating) {
    case 1:
    case 2:
      return const Color(0xFF2EA9DE);
    case 3:
      return const Color(0xFF5C6BC0);
    case 4:
      return const Color(0xFFE67E22);
    case 5:
      return const Color(0xFFDB3A34);
    default:
      return const Color(0xFF2EA9DE);
  }
}

String? scenarioErrorText(AsyncValue<List<ScenarioOption>> scenarioState) {
  if (!scenarioState.hasError) return null;
  final error = scenarioState.error;
  if (error is Failure) {
    return error.message;
  }
  return 'Could not load scenarios. Tap to retry.';
}
