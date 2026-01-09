import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

class AppModal extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? body;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Color? primaryColor;
  final IconData? icon;
  final Color? iconColor;

  const AppModal({
    super.key,
    required this.title,
    this.description,
    this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrimary = primaryLabel != null && onPrimary != null;
    final hasSecondary = secondaryLabel != null && onSecondary != null;
    final hasActions = hasPrimary || hasSecondary;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? const Color(0xFF2EA9DE), size: 42),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1A1E),
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A5560),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (body != null) ...[const SizedBox(height: 16), body!],
            if (hasActions) ...[
              const SizedBox(height: 24),
              if (hasPrimary)
                PrimaryButton(
                  onPressed: onPrimary,
                  backgroundColor: primaryColor ?? const Color(0xFF2EA9DE),
                  enableShimmer: true,
                  child: Text(
                    primaryLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (hasSecondary) ...[
                const SizedBox(height: 8),
                SecondaryButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryLabel!,
                    style: const TextStyle(
                      color: Color(0xFF4A5560),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
