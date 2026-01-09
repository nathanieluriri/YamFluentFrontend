import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/onboarding_draft.dart';
import '../../domain/onboarding_options.dart';
import '../onboarding_controller.dart';
import '../../../../../ui/widgets/layouts/step_scaffold.dart';
import '../../../../../ui/widgets/modals/search_picker_sheet.dart';
import '../../../../../ui/widgets/common/app_snackbar.dart';

class NativeLanguageStep extends ConsumerWidget {
  final OnboardingOptions options;
  final OnboardingDraft draft;
  final VoidCallback? onBack;
  final VoidCallback onProceed;

  const NativeLanguageStep({
    super.key,
    required this.options,
    required this.draft,
    required this.onBack,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = draft.nativeLanguage;
    return StepScaffold(
      currentStep: 0,
      totalSteps: 5,
      title: 'Native Language',
      subtitle: 'This helps us personalize your fluency training',
      activeIconPath: 'assets/icons/native_language.png',
      onBack: onBack,
      proceedEnabled: draft.nativeLanguage != null,
      onProceed: onProceed,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF002331),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Native Language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () =>
                    _openLanguagePicker(context, ref, options.nativeLanguages),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedLanguage ?? 'Select your language',
                          style: TextStyle(
                            color: selectedLanguage == null
                                ? Colors.grey
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    List<String> languages,
  ) async {
    if (languages.isEmpty) {
      showAppSnackBar(context, 'No languages available.');
      return;
    }
    final selected = await SearchPickerSheet.show(
      context,
      items: languages,
      placeholder: 'Search language',
      emptyTitle: 'No language found.',
      emptySubtitle: 'Try a different search term.',
    );
    if (selected != null) {
      ref.read(onboardingDraftProvider.notifier).setNativeLanguage(selected);
    }
  }
}
