import 'package:flutter/material.dart';
import '../widgets/store_button.dart';

class DownloadSection extends StatelessWidget {
  const DownloadSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 60 : 80,
      ),
      padding: EdgeInsets.all(isMobile ? 40 : 80),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
            Color(0xFFEC4899),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Download Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),

          // Title
          Text(
            'Start Your Journey Today',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Subtitle
          Text(
            'Join thousands of users building better habits.\n'
            'Available on iOS and Android.',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 40 : 48),

          // Store buttons
          if (isMobile)
            Column(
              children: [
                StoreButton(
                  type: StoreButtonType.appStore,
                  onTap: () {
                    // TODO: Add App Store link
                  },
                ),
                const SizedBox(height: 16),
                StoreButton(
                  type: StoreButtonType.playStore,
                  onTap: () {
                    // TODO: Add Play Store link
                  },
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StoreButton(
                  type: StoreButtonType.appStore,
                  onTap: () {
                    // TODO: Add App Store link
                  },
                ),
                const SizedBox(width: 24),
                StoreButton(
                  type: StoreButtonType.playStore,
                  onTap: () {
                    // TODO: Add Play Store link
                  },
                ),
              ],
            ),

          SizedBox(height: isMobile ? 24 : 32),

          // Trust indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrustBadge(
                Icons.verified_user_rounded,
                'Secure & Private',
                isMobile,
              ),
              SizedBox(width: isMobile ? 16 : 32),
              _buildTrustBadge(
                Icons.phone_android_rounded,
                'iOS & Android',
                isMobile,
              ),
              SizedBox(width: isMobile ? 16 : 32),
              _buildTrustBadge(
                Icons.currency_exchange_rounded,
                'Free to Start',
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String label, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: isMobile ? 16 : 20,
        ),
        SizedBox(width: isMobile ? 4 : 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
