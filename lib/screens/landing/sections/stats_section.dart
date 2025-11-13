import 'package:flutter/material.dart';

class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return VisibilityDetector(
      onVisibilityChanged: (visible) {
        if (visible && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 80,
          vertical: isMobile ? 60 : 100,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            if (isMobile)
              ..._buildMobileStats()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildStats(),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStats() {
    return [
      _buildStatCard('50,000+', 'Active Users', Icons.people_rounded),
      _buildStatCard('1M+', 'Habits Completed', Icons.check_circle_rounded),
      _buildStatCard('98%', 'Success Rate', Icons.trending_up_rounded),
      _buildStatCard('4.9★', 'App Rating', Icons.star_rounded),
    ];
  }

  List<Widget> _buildMobileStats() {
    final stats = _buildStats();
    return [
      Row(
        children: [
          Expanded(child: stats[0]),
          const SizedBox(width: 16),
          Expanded(child: stats[1]),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: stats[2]),
          const SizedBox(width: 16),
          Expanded(child: stats[3]),
        ],
      ),
    ];
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _isVisible ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.5 + (animValue * 0.5),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCounter(
            value: value,
            visible: _isVisible,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  final String value;
  final bool visible;

  const AnimatedCounter({
    required this.value,
    required this.visible,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: visible ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Text(
          _getAnimatedValue(animValue),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        );
      },
    );
  }

  String _getAnimatedValue(double progress) {
    if (value.contains('★')) {
      final numValue = double.parse(value.replaceAll('★', ''));
      return '${(numValue * progress).toStringAsFixed(1)}★';
    } else if (value.contains('%')) {
      final numValue = int.parse(value.replaceAll('%', ''));
      return '${(numValue * progress).toInt()}%';
    } else if (value.contains('K')) {
      final numValue =
          double.parse(value.replaceAll('K+', '').replaceAll(',', ''));
      return '${(numValue * progress).toStringAsFixed(0)}K+';
    } else if (value.contains('M')) {
      final numValue = int.parse(value.replaceAll('M+', ''));
      return '${(numValue * progress).toInt()}M+';
    }
    return value;
  }
}

class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final Function(bool) onVisibilityChanged;

  const VisibilityDetector({
    required this.child,
    required this.onVisibilityChanged,
    super.key,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            final size = MediaQuery.of(context).size;
            final visible = position.dy < size.height &&
                position.dy > -renderBox.size.height;
            widget.onVisibilityChanged(visible);
          }
        });
        return widget.child;
      },
    );
  }
}
