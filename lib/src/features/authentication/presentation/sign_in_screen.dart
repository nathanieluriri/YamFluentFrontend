import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
import '../../../../../ui/widgets/layouts/background_layout.dart';
import '../../../../../ui/widgets/buttons/primary_button.dart';
import '../../../../../ui/widgets/buttons/secondary_button.dart';
import '../../../../../ui/widgets/buttons/tertiary_action_button.dart';
import '../../../../../ui/widgets/checkboxes/app_checkbox.dart';
import '../../../../../ui/widgets/dividers/or_divider.dart';
import '../../../../../ui/widgets/inputs/app_text_field.dart';
import '../../../../../ui/widgets/loaders/yamfluent_loader_inline.dart';
import '../../../../../ui/widgets/common/app_snackbar.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _acceptedPolicies = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_acceptedPolicies) {
      showAppSnackBar(
        context,
        'Please accept terms and privacy policy to continue.',
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  void _togglePolicies() {
    setState(() => _acceptedPolicies = !_acceptedPolicies);
  }

  Widget _buildPolicyLabel() {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
        children: [
          TextSpan(
            text: 'By signing in you agree to our ',
            recognizer: TapGestureRecognizer()..onTap = _togglePolicies,
          ),
          TextSpan(
            text: 'terms of services',
            style: const TextStyle(
              color: Color(0xFF2EA9DE),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF2EA9DE),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.pushNamed('terms_of_service');
              },
          ),
          TextSpan(
            text: ' and ',
            recognizer: TapGestureRecognizer()..onTap = _togglePolicies,
          ),
          TextSpan(
            text: 'privacy policy',
            style: const TextStyle(
              color: Color(0xFF2EA9DE),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF2EA9DE),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.pushNamed('privacy_policy');
              },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (previous, next) {
      if (!next.hasError) return;
      if (previous?.hasError == true && previous?.error == next.error) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAppSnackBar(
          context,
          'Login failed: ${formatSnackBarError(next.error)}',
        );
      });
    });

    return AuthBackgroundLayout(
      topOffset: 44,
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
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Log back into your account to access and save your Session history across app restarts safely',
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
              const SizedBox(height: 12),
              AppTextField(
                controller: _passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Password too short',
              ),
              const SizedBox(height: 24),
              AppCheckbox(
                value: _acceptedPolicies,
                onChanged: (v) => setState(() => _acceptedPolicies = v ?? false),
                toggleOnLabelTap: false,
                label: _buildPolicyLabel(),
              ),
              const SizedBox(height: 16),
              if (authState.isLoading)
                const YamFluentLoaderInline()
              else
                PrimaryButton(
                  onPressed: _acceptedPolicies ? _submit : null,
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 44),
              const OrDivider(),
              const SizedBox(height: 16),
              SecondaryButton(
                onPressed: _isGoogleLoading
                    ? null
                    : () async {
                        setState(() => _isGoogleLoading = true);
                        try {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle(silent: true);
                        } catch (e) {
                          if (!mounted) return;
                          showAppSnackBar(
                            context,
                            formatSnackBarError(e),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isGoogleLoading = false);
                          }
                        }
                      },
                leading: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  child: _isGoogleLoading
                      ? const YamFluentLoaderInline(key: ValueKey('loader'))
                      : Image.asset(
                          'assets/icons/google_g.png',
                          key: const ValueKey('icon'),
                          height: 22,
                          width: 22,
                        ),
                ),
                child: const Text(
                  'Continue with google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TertiaryActionButton(
                label: "Don't have an account?",
                actionText: 'Create an account.',
                onPressed: () => context.pushNamed('signup'),
              ),

              TertiaryActionButton(
                label: "Can't remember password?",
                actionText: 'Create a new password.',
                onPressed: () => context.pushNamed('forgot_password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
