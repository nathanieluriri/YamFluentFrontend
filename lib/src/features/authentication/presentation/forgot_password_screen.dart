import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../../../../ui/widgets/layouts/background_layout.dart';
import '../../../../../ui/widgets/buttons/primary_button.dart';
import '../../../../../ui/widgets/buttons/tertiary_action_button.dart';
import '../../../../../ui/widgets/inputs/app_text_field.dart';
import '../../../../../ui/widgets/loaders/yamfluent_loader_inline.dart';
import '../../../../../ui/widgets/common/app_snackbar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final detail = await ref
            .read(authControllerProvider.notifier)
            .requestPasswordReset(_emailController.text);
        final message = detail.toLowerCase().contains('email')
            ? detail
            : '$detail Check your email.';
        if (mounted) {
          showAppSnackBar(context, message);
          context.pop(); // Go back to login
        }
      } catch (e) {
        if (mounted) {
          showAppSnackBar(context, 'Error: ${formatSnackBarError(e)}');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundLayout(
      topOffset: 60,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64,),
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _emailController,
                hintText: 'Enter your email address',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Enter a valid email',
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const YamFluentLoaderInline()
              else
                PrimaryButton(
                  onPressed: _submit,
                  child: const Text(
                    'Send Reset Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TertiaryActionButton(
                label: 'Remembered your password?',
                actionText: 'Back to sign in.',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
