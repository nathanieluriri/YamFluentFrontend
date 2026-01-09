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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.resetToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildAppSnackBar('Invalid reset token'),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final detail = await ref
            .read(authControllerProvider.notifier)
            .confirmPasswordReset(widget.resetToken, _passwordController.text);
        if (mounted) {
          showAppSnackBar(context, detail);
          context.goNamed('login');
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
              const SizedBox(height: 64),
              Text(
                'Set New Password',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter a new password for your account.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _passwordController,
                hintText: 'New password',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmController,
                hintText: 'Confirm new password',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                validator: (value) =>
                    value == _passwordController.text ? null : 'Passwords do not match',
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const YamFluentLoaderInline()
              else
                PrimaryButton(
                  onPressed: _submit,
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TertiaryActionButton(
                label: 'Back to sign in',
                actionText: 'Return to login.',
                onPressed: () => context.goNamed('login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
