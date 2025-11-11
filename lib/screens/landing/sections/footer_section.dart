import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(isMobile ? 40 : 80),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (isMobile)
            _buildMobileFooter(context)
          else
            _buildDesktopFooter(context),

          const SizedBox(height: 48),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 32),

          // Bottom row
          if (isMobile)
            Column(
              children: [
                Text(
                  '© 2025 Habit Hero. All rights reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildSocialLinks(),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2025 Habit Hero. All rights reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                _buildSocialLinks(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      children: [
        _buildBrand(),
        const SizedBox(height: 40),
        _buildLinkColumn(
            'Product',
            [
              'Features',
              'Pricing',
              'Download',
              'Roadmap',
            ],
            context),
        const SizedBox(height: 32),
        _buildLinkColumn(
            'Company',
            [
              'About Us',
              'Blog',
              'Careers',
              'Contact',
            ],
            context),
        const SizedBox(height: 32),
        _buildLinkColumn(
            'Legal',
            [
              'Privacy Policy',
              'Terms of Service',
              'Cookie Policy',
              'GDPR',
            ],
            context),
      ],
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildBrand(),
        ),
        Expanded(
          child: _buildLinkColumn(
              'Product',
              [
                'Features',
                'Pricing',
                'Download',
                'Roadmap',
              ],
              context),
        ),
        Expanded(
          child: _buildLinkColumn(
              'Company',
              [
                'About Us',
                'Blog',
                'Careers',
                'Contact',
              ],
              context),
        ),
        Expanded(
          child: _buildLinkColumn(
              'Legal',
              [
                'Privacy Policy',
                'Terms of Service',
                'Cookie Policy',
                'GDPR',
              ],
              context),
        ),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Habit Hero',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Build better habits together.\nTransform your life, one day at a time.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkColumn(
      String title, List<String> links, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildFooterLink(link, context),
            )),
      ],
    );
  }

  Widget _buildFooterLink(String text, BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleLinkTap(text, context),
        child: HoverText(
          text: text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          hoverStyle: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleLinkTap(String text, BuildContext context) {
    // Navigate to pages based on link text
    if (text == 'Privacy Policy') {
      Navigator.pushNamed(context, '/privacy');
    } else if (text == 'Terms of Service') {
      Navigator.pushNamed(context, '/terms');
    }
    // Other links can be implemented as needed
  }

  Widget _buildSocialLinks() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialButton(Icons.public_rounded, 'Twitter'),
        const SizedBox(width: 16),
        _buildSocialButton(Icons.facebook_rounded, 'Facebook'),
        const SizedBox(width: 16),
        _buildSocialButton(Icons.camera_alt_rounded, 'Instagram'),
        const SizedBox(width: 16),
        _buildSocialButton(Icons.video_library_rounded, 'YouTube'),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Open social media links
        },
        child: Tooltip(
          message: label,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class HoverText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextStyle hoverStyle;

  const HoverText({
    required this.text,
    required this.style,
    required this.hoverStyle,
    super.key,
  });

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: _isHovered ? widget.hoverStyle : widget.style,
        child: Text(widget.text),
      ),
    );
  }
}
