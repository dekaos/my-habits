import 'package:flutter/material.dart';
import '../widgets/page_header.dart';
import '../sections/footer_section.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
              title: 'Privacy Policy',
              subtitle: 'How we collect, use, and protect your information',
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
                    'Introduction',
                    'Welcome to Habit Hero ("we," "our," or "us"). We are committed to protecting your '
                        'privacy and ensuring the security of your personal information. This Privacy Policy '
                        'explains how we collect, use, disclose, and safeguard your information when you use '
                        'our mobile application and services.',
                  ),

                  _buildSection(
                    context,
                    '1. Information We Collect',
                    '',
                    subsections: [
                      _buildSubsection(
                        context,
                        '1.1 Personal Information',
                        'When you create an account, we collect:\n'
                            '• Email address\n'
                            '• Username\n'
                            '• Profile picture (optional)\n'
                            '• Password (encrypted)',
                      ),
                      _buildSubsection(
                        context,
                        '1.2 Habit Data',
                        'We collect information about your habits and activities:\n'
                            '• Habit names and descriptions\n'
                            '• Completion records and streaks\n'
                            '• Custom icons and preferences\n'
                            '• Progress statistics',
                      ),
                      _buildSubsection(
                        context,
                        '1.3 Social Features',
                        'When you use our social features:\n'
                            '• Friend connections and requests\n'
                            '• Messages and activity posts\n'
                            '• Reactions and interactions\n'
                            '• Shared progress updates',
                      ),
                      _buildSubsection(
                        context,
                        '1.4 Usage Information',
                        'We automatically collect:\n'
                            '• Device information (type, OS version)\n'
                            '• App usage patterns and features used\n'
                            '• Crash reports and error logs\n'
                            '• Analytics data (anonymized)',
                      ),
                    ],
                  ),

                  _buildSection(
                    context,
                    '2. How We Use Your Information',
                    'We use your information to:\n'
                        '• Provide and maintain our services\n'
                        '• Personalize your experience\n'
                        '• Send notifications and reminders\n'
                        '• Facilitate social features and friend connections\n'
                        '• Analyze usage to improve our app\n'
                        '• Detect and prevent fraud or abuse\n'
                        '• Communicate updates and support responses',
                  ),

                  _buildSection(
                    context,
                    '3. Data Sharing and Disclosure',
                    'We do NOT sell your personal information. We may share data only:\n'
                        '• With your explicit consent\n'
                        '• With friends you choose to connect with (limited habit data)\n'
                        '• With service providers who assist our operations (under strict agreements)\n'
                        '• When required by law or to protect rights and safety\n'
                        '• In connection with a business transfer or merger',
                  ),

                  _buildSection(
                    context,
                    '4. Data Security',
                    'We implement industry-standard security measures:\n'
                        '• Encryption in transit (HTTPS/TLS)\n'
                        '• Encryption at rest for sensitive data\n'
                        '• Secure authentication (hashed passwords)\n'
                        '• Regular security audits\n'
                        '• Access controls and monitoring\n\n'
                        'However, no method of transmission over the internet is 100% secure. '
                        'We cannot guarantee absolute security.',
                  ),

                  _buildSection(
                    context,
                    '5. Your Rights and Choices',
                    'You have the right to:\n'
                        '• Access your personal data\n'
                        '• Correct inaccurate information\n'
                        '• Delete your account and data\n'
                        '• Export your data (data portability)\n'
                        '• Opt-out of marketing communications\n'
                        '• Control social sharing settings\n'
                        '• Disable notifications\n\n'
                        'To exercise these rights, contact us at privacy@habithero.app',
                  ),

                  _buildSection(
                    context,
                    '6. Data Retention',
                    'We retain your information:\n'
                        '• Account data: Until you delete your account\n'
                        '• Habit data: Until you delete specific habits or your account\n'
                        '• Messages: As long as your account is active\n'
                        '• Analytics: Anonymized data retained indefinitely\n'
                        '• Backups: Deleted within 90 days of account deletion',
                  ),

                  _buildSection(
                    context,
                    '7. Children\'s Privacy',
                    'Our service is not intended for children under 13 years of age. '
                        'We do not knowingly collect personal information from children under 13. '
                        'If we discover that a child under 13 has provided us with personal information, '
                        'we will delete such information immediately.',
                  ),

                  _buildSection(
                    context,
                    '8. International Data Transfers',
                    'Your information may be transferred to and processed in countries other than your own. '
                        'We ensure appropriate safeguards are in place to protect your information in accordance '
                        'with this Privacy Policy.',
                  ),

                  _buildSection(
                    context,
                    '9. Third-Party Services',
                    'We use third-party services that may collect information:\n'
                        '• Analytics providers (e.g., Google Analytics)\n'
                        '• Cloud hosting (Supabase)\n'
                        '• Authentication services\n'
                        '• Push notification services\n\n'
                        'These services have their own privacy policies governing their use of your information.',
                  ),

                  _buildSection(
                    context,
                    '10. Cookies and Tracking',
                    'We use cookies and similar technologies to:\n'
                        '• Keep you logged in\n'
                        '• Remember your preferences\n'
                        '• Analyze app usage\n'
                        '• Improve performance\n\n'
                        'You can control cookie settings through your browser or device.',
                  ),

                  _buildSection(
                    context,
                    '11. Changes to This Policy',
                    'We may update this Privacy Policy from time to time. We will notify you of significant '
                        'changes via email or in-app notification. Continued use of our services after changes '
                        'constitutes acceptance of the updated policy.',
                  ),

                  _buildSection(
                    context,
                    '12. Contact Us',
                    'If you have questions or concerns about this Privacy Policy:\n\n'
                        'Email: privacy@habithero.app\n'
                        'Website: https://habithero.app\n\n'
                        'For data protection inquiries in the EU, contact our Data Protection Officer at dpo@habithero.app',
                  ),

                  const SizedBox(height: 60),

                  // GDPR/CCPA Notice
                  _buildHighlightBox(
                    context,
                    'Your Privacy Rights',
                    'If you are a resident of California (CCPA) or the European Union (GDPR), '
                        'you have additional rights regarding your personal information. '
                        'Contact us to exercise these rights or learn more.',
                    Icons.shield_rounded,
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
