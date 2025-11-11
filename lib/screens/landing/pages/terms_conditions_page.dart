import 'package:flutter/material.dart';
import '../widgets/page_header.dart';
import '../sections/footer_section.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            PageHeader(
              title: 'Terms & Conditions',
              subtitle:
                  'Please read these terms carefully before using Habit Hero',
              isMobile: isMobile,
            ),

            // Content
            Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 48,
                vertical: isMobile ? 40 : 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLastUpdated(context),
                  const SizedBox(height: 40),

                  _buildSection(
                    context,
                    'Agreement to Terms',
                    'By accessing or using Habit Hero ("the App"), you agree to be bound by these Terms '
                        'and Conditions. If you disagree with any part of these terms, you may not access the App. '
                        'These Terms apply to all users, including visitors, registered users, and any other users '
                        'of the App.',
                  ),

                  _buildSection(
                    context,
                    '1. Use License',
                    '',
                    subsections: [
                      _buildSubsection(
                        context,
                        '1.1 Grant of License',
                        'Habit Hero grants you a personal, non-exclusive, non-transferable, limited license to '
                            'use the App on your personal devices in accordance with these Terms.',
                      ),
                      _buildSubsection(
                        context,
                        '1.2 Restrictions',
                        'You may not:\n'
                            '• Modify, copy, or distribute the App\n'
                            '• Reverse engineer or decompile the App\n'
                            '• Remove any copyright or proprietary notices\n'
                            '• Use the App for any unlawful purpose\n'
                            '• Transfer or sublicense your rights to any other person\n'
                            '• Use the App to harass, abuse, or harm others',
                      ),
                    ],
                  ),

                  _buildSection(
                    context,
                    '2. User Accounts',
                    '',
                    subsections: [
                      _buildSubsection(
                        context,
                        '2.1 Account Creation',
                        'To use certain features, you must create an account. You agree to:\n'
                            '• Provide accurate and complete information\n'
                            '• Maintain the security of your password\n'
                            '• Accept responsibility for all activities under your account\n'
                            '• Notify us immediately of unauthorized access',
                      ),
                      _buildSubsection(
                        context,
                        '2.2 Account Termination',
                        'We reserve the right to terminate or suspend your account at any time for:\n'
                            '• Violation of these Terms\n'
                            '• Fraudulent or illegal activity\n'
                            '• Extended inactivity\n'
                            '• Any reason at our sole discretion',
                      ),
                    ],
                  ),

                  _buildSection(
                    context,
                    '3. User Content',
                    '',
                    subsections: [
                      _buildSubsection(
                        context,
                        '3.1 Content Ownership',
                        'You retain ownership of all content you create in the App (habits, notes, messages). '
                            'By using the App, you grant us a license to use, store, and display your content '
                            'solely for the purpose of providing our services.',
                      ),
                      _buildSubsection(
                        context,
                        '3.2 Content Standards',
                        'You agree not to post content that:\n'
                            '• Violates any laws or regulations\n'
                            '• Infringes on intellectual property rights\n'
                            '• Contains hate speech, harassment, or threats\n'
                            '• Is sexually explicit or promotes violence\n'
                            '• Contains spam or malicious code\n'
                            '• Impersonates any person or entity',
                      ),
                      _buildSubsection(
                        context,
                        '3.3 Content Moderation',
                        'We reserve the right to review, remove, or modify any user content that violates '
                            'these Terms or is otherwise objectionable.',
                      ),
                    ],
                  ),

                  _buildSection(
                    context,
                    '4. Social Features',
                    'Our App includes social features such as friend connections, messaging, and progress sharing. '
                        'You agree to:\n'
                        '• Respect other users\n'
                        '• Not misuse social features for harassment or spam\n'
                        '• Control your own privacy settings\n'
                        '• Report any abusive behavior\n\n'
                        'We are not responsible for interactions between users.',
                  ),

                  _buildSection(
                    context,
                    '5. Subscription and Payments',
                    '',
                    subsections: [
                      _buildSubsection(
                        context,
                        '5.1 Free and Premium Features',
                        'Habit Hero offers both free and premium features. Premium features require a subscription.',
                      ),
                      _buildSubsection(
                        context,
                        '5.2 Billing',
                        '• Subscriptions are billed through app stores (Apple App Store, Google Play Store)\n'
                            '• Charges are non-refundable except as required by law\n'
                            '• Subscriptions auto-renew unless cancelled\n'
                            '• Prices may change with notice',
                      ),
                      _buildSubsection(
                        context,
                        '5.3 Cancellation',
                        'You may cancel your subscription at any time through your app store account settings. '
                            'Cancellation takes effect at the end of the current billing period.',
                      ),
                    ],
                  ),

                  _buildSection(
                    context,
                    '6. Intellectual Property',
                    'The App and its original content, features, and functionality are owned by Habit Hero '
                        'and are protected by international copyright, trademark, patent, trade secret, and other '
                        'intellectual property laws. Our trademarks may not be used without prior written consent.',
                  ),

                  _buildSection(
                    context,
                    '7. Third-Party Links and Services',
                    'The App may contain links to third-party websites or services. We are not responsible for '
                        'the content, privacy policies, or practices of any third-party sites or services. You access '
                        'them at your own risk.',
                  ),

                  _buildSection(
                    context,
                    '8. Disclaimers',
                    '',
                    subsections: [
                      _buildSubsection(
                        context,
                        '8.1 "As Is" Service',
                        'The App is provided "AS IS" and "AS AVAILABLE" without warranties of any kind, either '
                            'express or implied, including but not limited to warranties of merchantability, fitness '
                            'for a particular purpose, or non-infringement.',
                      ),
                      _buildSubsection(
                        context,
                        '8.2 No Medical Advice',
                        'Habit Hero is not a substitute for professional medical advice, diagnosis, or treatment. '
                            'Always consult with qualified healthcare providers for health-related questions.',
                      ),
                      _buildSubsection(
                        context,
                        '8.3 Availability',
                        'We do not guarantee that the App will be available at all times. We may experience '
                            'interruptions, delays, or errors.',
                      ),
                    ],
                  ),

                  _buildSection(
                    context,
                    '9. Limitation of Liability',
                    'To the maximum extent permitted by law, Habit Hero shall not be liable for any indirect, '
                        'incidental, special, consequential, or punitive damages, or any loss of profits or revenues, '
                        'whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible '
                        'losses resulting from:\n'
                        '• Your use or inability to use the App\n'
                        '• Any unauthorized access to your account\n'
                        '• Any bugs, viruses, or similar issues\n'
                        '• Any errors or omissions in content\n'
                        '• Any conduct or content of third parties',
                  ),

                  _buildSection(
                    context,
                    '10. Indemnification',
                    'You agree to indemnify, defend, and hold harmless Habit Hero and its officers, directors, '
                        'employees, and agents from any claims, liabilities, damages, losses, and expenses arising out of '
                        'your use of the App or violation of these Terms.',
                  ),

                  _buildSection(
                    context,
                    '11. Changes to Terms',
                    'We reserve the right to modify these Terms at any time. We will notify users of material '
                        'changes via email or in-app notification. Your continued use of the App after changes constitutes '
                        'acceptance of the new Terms.',
                  ),

                  _buildSection(
                    context,
                    '12. Governing Law',
                    'These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], '
                        'without regard to its conflict of law provisions. Any disputes shall be resolved in the courts of '
                        '[Your Jurisdiction].',
                  ),

                  _buildSection(
                    context,
                    '13. Dispute Resolution',
                    '',
                    subsections: [
                      _buildSubsection(
                        context,
                        '13.1 Informal Resolution',
                        'In the event of any dispute, you agree to first contact us to attempt to resolve the dispute '
                            'informally.',
                      ),
                      _buildSubsection(
                        context,
                        '13.2 Arbitration',
                        'If informal resolution is unsuccessful, disputes shall be resolved through binding arbitration '
                            'in accordance with [Arbitration Association] rules. You waive any right to a jury trial.',
                      ),
                      _buildSubsection(
                        context,
                        '13.3 Class Action Waiver',
                        'You agree to bring claims only in your individual capacity and not as part of any class or '
                            'representative action.',
                      ),
                    ],
                  ),

                  _buildSection(
                    context,
                    '14. Severability',
                    'If any provision of these Terms is found to be unenforceable or invalid, that provision will be '
                        'limited or eliminated to the minimum extent necessary, and the remaining provisions will remain in '
                        'full force and effect.',
                  ),

                  _buildSection(
                    context,
                    '15. Entire Agreement',
                    'These Terms constitute the entire agreement between you and Habit Hero regarding the use of the App '
                        'and supersede all prior agreements and understandings.',
                  ),

                  _buildSection(
                    context,
                    '16. Contact Information',
                    'For questions about these Terms, please contact us:\n\n'
                        'Email: legal@habithero.app\n'
                        'Website: https://habithero.app\n'
                        'Address: [Your Business Address]',
                  ),

                  const SizedBox(height: 60),

                  // Important notice
                  _buildHighlightBox(
                    context,
                    'Important Notice',
                    'By using Habit Hero, you acknowledge that you have read, understood, and agree to be bound '
                        'by these Terms and Conditions.',
                    Icons.gavel_rounded,
                  ),
                ],
              ),
            ),

            // Footer
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF6366F1),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Last Updated: November 11, 2025',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content, {
    List<Widget>? subsections,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          if (content.isNotEmpty)
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
            ),
          if (subsections != null) ...subsections,
        ],
      ),
    );
  }

  Widget _buildSubsection(
    BuildContext context,
    String title,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBox(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
