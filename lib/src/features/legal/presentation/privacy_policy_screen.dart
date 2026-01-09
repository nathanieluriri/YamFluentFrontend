import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../ui/widgets/layouts/background_layout.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackgroundLayout(
      topOffset: 56,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2EA9DE),
                    ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 20),
              _buildSection(
                context,
                'Introduction',
                'Welcome to YamFluent! This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our language learning app. By using YamFluent, you agree to the collection and use of information in accordance with this policy.',
                delay: 200.ms,
              ),
              _buildSection(
                context,
                'Information We Collect',
                'We collect information you provide directly to us, such as when you create an account, update your profile, or contact us for support. This may include your name, email address, and learning preferences. We also collect usage data automatically, including your interactions with the app, progress in lessons, and device information.',
                delay: 400.ms,
              ),
              _buildSection(
                context,
                'How We Use Your Information',
                'Your information helps us provide, maintain, and improve YamFluent. We use it to personalize your learning experience, send you important updates, respond to your inquiries, and analyze usage patterns to enhance our services. We may also use aggregated data for research and development purposes.',
                delay: 600.ms,
              ),
              _buildSection(
                context,
                'Data Sharing and Disclosure',
                'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy. We may share information with service providers who assist us in operating the app, or when required by law. Your data is stored securely and only accessed on a need-to-know basis.',
                delay: 800.ms,
              ),
              _buildSection(
                context,
                'Data Security',
                'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes encryption, secure servers, and regular security audits. However, no method of transmission over the internet is 100% secure.',
                delay: 1000.ms,
              ),
              _buildSection(
                context,
                'Your Rights and Choices',
                'You have the right to access, update, or delete your personal information. You can manage your account settings within the app or contact us directly. We will respond to your requests in accordance with applicable data protection laws. You may also opt out of certain communications at any time.',
                delay: 1200.ms,
              ),
              _buildSection(
                context,
                'Changes to This Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date. Your continued use of YamFluent after any changes constitutes acceptance of the updated policy.',
                delay: 1400.ms,
              ),
              _buildSection(
                context,
                'Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at privacy@yamfluent.com or through the support section in the app. We are committed to addressing your concerns and ensuring your privacy rights are respected.',
                delay: 1600.ms,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content, {
    required Duration delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F3D47),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay, duration: 600.ms).slideY(begin: 0.2);
  }
}
