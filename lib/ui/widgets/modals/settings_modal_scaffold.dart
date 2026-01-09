import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';
import '../loaders/yamfluent_loader_inline.dart';

class SettingsModalScaffold extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget child;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final bool primaryEnabled;
  final bool isSubmitting;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const SettingsModalScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onPrimary,
    required this.onSecondary,
    this.primaryLabel = 'Save',
    this.secondaryLabel = 'Cancel',
    this.primaryEnabled = true,
    this.isSubmitting = false,
    this.initialChildSize = 0.75,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        final canSubmit = primaryEnabled && !isSubmitting && onPrimary != null;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EDF1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF3F8FB),
                    ),
                    child: Center(child: icon),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B6B73),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                child,
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: canSubmit ? onPrimary : null,
                  child: isSubmitting
                      ? const YamFluentLoaderInline(
                          key: ValueKey('settings-modal-loader'),
                        )
                      : Text(
                          primaryLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSecondary,
                  child: Text(
                    secondaryLabel,
                    style: const TextStyle(
                      color: Color(0xFF5B6B73),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
