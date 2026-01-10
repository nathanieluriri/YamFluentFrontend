import 'package:flutter/material.dart';
import '../../../../ui/widgets/modals/app_modal.dart';

class BreathingConfirmationModal extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onCancel;

  const BreathingConfirmationModal({
    super.key,
    required this.onStart,
    required this.onCancel,
  });

  
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onStart,
    required VoidCallback onCancel,
  }) async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BreathingConfirmationModal(onStart: onStart, onCancel: onCancel);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return AppModal(
      title: 'Before you start…',
      description:
          'You\'ll do a quick breathing exercise (45–60 seconds) before speaking.',
      primaryLabel: 'Start breathing',
      onPrimary: onStart,
      secondaryLabel: 'Cancel',
      onSecondary: onCancel,
      icon: Icons.spa_outlined,
      iconColor: const Color(0xFF2EA9DE),
    );
  }
}
