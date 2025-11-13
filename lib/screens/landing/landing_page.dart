import 'package:flutter/material.dart';
import 'sections/hero_section.dart';
import 'sections/features_section.dart';
import 'sections/stats_section.dart';
import 'sections/download_section.dart';
import 'sections/footer_section.dart';
import 'widgets/floating_app_bar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingAppBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 100;
    if (show != _showFloatingAppBar) {
      setState(() => _showFloatingAppBar = show);
    }
  }

  void _scrollToSection(String section) {
    double offset = 0;
    switch (section) {
      case 'features':
        offset = 600;
        break;
      case 'download':
        offset = 1800;
        break;
    }
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            controller: _scrollController,
            child: const Column(
              children: [
                HeroSection(),
                StatsSection(),
                FeaturesSection(),
                DownloadSection(),
                FooterSection(),
              ],
            ),
          ),
          // Floating app bar
          FloatingAppBar(
            visible: _showFloatingAppBar,
            onNavigate: _scrollToSection,
          ),
        ],
      ),
    );
  }
}
