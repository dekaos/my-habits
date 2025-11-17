import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1200;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 80 : 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          // Section header
          Text(
            'Everything You Need to Succeed',
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Powerful features designed to help you build and maintain lasting habits',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 48 : 80),

          // Features grid
          if (isMobile)
            ..._buildFeatures().map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: feature,
                ))
          else if (isTablet)
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeatures()[0]),
                    const SizedBox(width: 24),
                    Expanded(child: _buildFeatures()[1]),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeatures()[2]),
                    const SizedBox(width: 24),
                    Expanded(child: _buildFeatures()[3]),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeatures()[4]),
                    const SizedBox(width: 24),
                    Expanded(child: _buildFeatures()[5]),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeatures()[0]),
                    const SizedBox(width: 32),
                    Expanded(child: _buildFeatures()[1]),
                    const SizedBox(width: 32),
                    Expanded(child: _buildFeatures()[2]),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFeatures()[3]),
                    const SizedBox(width: 32),
                    Expanded(child: _buildFeatures()[4]),
                    const SizedBox(width: 32),
                    Expanded(child: _buildFeatures()[5]),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatures() {
    return [
      const FeatureCard(
        icon: Icons.people_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        title: 'Social Accountability',
        description:
            'Connect with friends, share progress, and motivate each other to stay on track.',
        index: 0,
      ),
      const FeatureCard(
        icon: Icons.insights_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        title: 'Smart Analytics',
        description:
            'Beautiful charts and insights to track your progress and identify patterns.',
        index: 1,
      ),
      const FeatureCard(
        icon: Icons.notifications_active_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
        ),
        title: 'Smart Reminders',
        description:
            'Intelligent notifications that adapt to your schedule and never feel annoying.',
        index: 2,
      ),
      const FeatureCard(
        icon: Icons.emoji_events_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        ),
        title: 'Streaks & Rewards',
        description:
            'Gamified experience with streaks, achievements, and celebrations for milestones.',
        index: 3,
      ),
      const FeatureCard(
        icon: Icons.chat_bubble_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFF6366F1)],
        ),
        title: 'Real-time Chat',
        description:
            'Instant messaging with your accountability partners to stay connected and motivated.',
        index: 4,
      ),
      const FeatureCard(
        icon: Icons.lock_rounded,
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
        ),
        title: 'Privacy First',
        description:
            'Your data is encrypted and secure. Choose what to share and with whom.',
        index: 5,
      ),
    ];
  }
}
