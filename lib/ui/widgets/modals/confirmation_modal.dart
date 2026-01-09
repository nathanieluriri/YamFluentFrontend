import 'package:flutter/material.dart';
import 'app_modal.dart';

class ConfirmationModal extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationModal({
    super.key,
    this.title = 'Are you sure?',
    required this.description,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppModal(
      title: title,
      description: description,
      primaryLabel: confirmLabel,
      primaryColor: confirmColor,
      onPrimary: onConfirm,
      secondaryLabel: 'Cancel',
      onSecondary: onCancel,
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFE03D3D),
    );
  }
}
