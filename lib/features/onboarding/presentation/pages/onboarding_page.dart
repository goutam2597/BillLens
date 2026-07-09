import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/router/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalPages = 3;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Never lose your\nreceipts again',
      subtitle:
          'Scan and save receipts digitally in seconds.\nYour expenses, always organized.',
      gradientColors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    ),
    _OnboardingData(
      title: 'AI understands\nyour expenses',
      subtitle:
          'Our intelligent engine categorizes your spending\nso you never have to manually sort again.',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    ),
    _OnboardingData(
      title: 'Save hours\nevery month',
      subtitle:
          'Auto-categorization, monthly reports, and\ntax-ready records at your fingertips.',
      gradientColors: [Color(0xFF059669), Color(0xFF10B981)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  void _skip() => context.go(AppRoutes.welcome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) =>
                _OnboardingSlide(data: _pages[index], pageIndex: index),
          ),

          // Top bar: Skip button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: _currentPage < _totalPages - 1 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dot indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _totalPages,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == _currentPage
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Next / Get Started button
                    GestureDetector(
                      onTap: _nextPage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _currentPage == _totalPages - 1
                                ? 'Get Started'
                                : 'Next',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _pages[_currentPage].gradientColors.first,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide data model ──────────────────────────────────────────────────────────

class _OnboardingData {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

// ── Individual slide ──────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final int pageIndex;

  const _OnboardingSlide({required this.data, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Illustration area
            Expanded(
              flex: 5,
              child: Center(child: _buildIllustration(pageIndex)),
            ),

            // Text content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ),
                    if (pageIndex == 1) ...[
                      const SizedBox(height: 24),
                      _buildAIChips(),
                    ],
                    if (pageIndex == 2) ...[
                      const SizedBox(height: 24),
                      _buildFeatureList(),
                    ],
                  ],
                ),
              ),
            ),

            // Space for bottom controls
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(int index) {
    final icons = [
      Icons.receipt_long_rounded,
      Icons.psychology_rounded,
      Icons.auto_graph_rounded,
    ];

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: Icon(
            icons[index],
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAIChips() {
    const chips = [
      ('☕ Starbucks', '→ Client Meeting'),
      ('📦 Amazon', '→ Office Supplies'),
      ('🚗 Uber', '→ Business Travel'),
    ];
    return Column(
      children: chips
          .map(
            (chip) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chip.$1,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    chip.$2,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFeatureList() {
    const features = [
      (Icons.category_rounded, 'Auto Categorization'),
      (Icons.bar_chart_rounded, 'Monthly Reports'),
      (Icons.receipt_rounded, 'Tax-Ready Records'),
    ];
    return Column(
      children: features
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(f.$1, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f.$2,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
