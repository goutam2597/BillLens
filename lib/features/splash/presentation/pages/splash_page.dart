import 'dart:async';

import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _scanController;
  Timer? _navigationTimer;
  bool _minimumDurationElapsed = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _navigationTimer = Timer(
      const Duration(milliseconds: 2500),
      _navigateFromCurrentState,
    );
  }

  void _navigateFromCurrentState() {
    if (!mounted) return;
    _minimumDurationElapsed = true;
    _navigateForState(context.read<AuthBloc>().state);
  }

  void _navigateForState(AuthState state) {
    if (state is Authenticated) {
      context.go(AppRoutes.dashboard);
    } else if (state is Unauthenticated || state is AuthError) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entryController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final overlayStyle =
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (_, state) {
        if (_minimumDurationElapsed) _navigateForState(state);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor:
              isDark ? const Color(0xFF07111F) : const Color(0xFFF7FAFC),
        ),
        child: Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF07111F),
                        Color(0xFF0D1B2A),
                        Color(0xFF10253A),
                      ]
                    : const [
                        Color(0xFFF9FCFF),
                        Color(0xFFF1F7FF),
                        Color(0xFFEAFBF6),
                      ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SplashPatternPainter(isDark: isDark),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StaggeredEntrance(
                                  animation: _entryController,
                                  interval: const Interval(0.08, 0.72),
                                  child: _AnimatedBrandMark(
                                    scanAnimation: _scanController,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _StaggeredEntrance(
                                  animation: _entryController,
                                  interval: const Interval(0.2, 0.78),
                                  offset: const Offset(0, 0.16),
                                  child: Text(
                                    'BillLens',
                                    style: GoogleFonts.outfit(
                                      color: foreground,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _StaggeredEntrance(
                                  animation: _entryController,
                                  interval: const Interval(0.3, 0.86),
                                  offset: const Offset(0, 0.2),
                                  child: Text(
                                    'See every spend clearly.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: foreground,
                                      fontSize: 20,
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _StaggeredEntrance(
                                  animation: _entryController,
                                  interval: const Interval(0.4, 1),
                                  offset: const Offset(0, 0.2),
                                  child: Text(
                                    'Your receipts, expenses, and insights\nin one focused view.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: secondary,
                                      fontSize: 15,
                                      height: 1.55,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _StaggeredEntrance(
                          animation: _entryController,
                          interval: const Interval(0.55, 1),
                          offset: const Offset(0, 0.25),
                          child: _LoadingStatus(
                            animation: _scanController,
                            secondary: secondary,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBrandMark extends StatelessWidget {
  const _AnimatedBrandMark({
    required this.scanAnimation,
    required this.isDark,
  });

  final Animation<double> scanAnimation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scanAnimation,
      builder: (context, _) {
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: scanAnimation.value * 0.08 - 0.04,
                child: Container(
                  width: 154,
                  height: 154,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    border: Border.all(
                      color: AppColors.accent.withValues(
                        alpha: isDark ? 0.18 : 0.22,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 132,
                height: 146,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF13283D)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.09)
                        : const Color(0xFFD9E5F2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.24 : 0.14,
                      ),
                      blurRadius: 38,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 64,
                ),
              ),
              Positioned(
                left: 34,
                right: 34,
                top: 38 + (scanAnimation.value * 104),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 18,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF07111F) : Colors.white,
                      width: 5,
                    ),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingStatus extends StatelessWidget {
  const _LoadingStatus({
    required this.animation,
    required this.secondary,
    required this.isDark,
  });

  final Animation<double> animation;
  final Color secondary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) => LinearProgressIndicator(
                value: 0.2 + animation.value * 0.7,
                minHeight: 3,
                color: AppColors.primary,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.borderLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Preparing your workspace',
          style: GoogleFonts.outfit(
            color: secondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StaggeredEntrance extends StatelessWidget {
  const _StaggeredEntrance({
    required this.animation,
    required this.interval,
    required this.child,
    this.offset = const Offset(0, 0.12),
  });

  final Animation<double> animation;
  final Interval interval;
  final Widget child;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (reducedMotion) return child;
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: offset, end: Offset.zero).animate(
          CurvedAnimation(parent: curved, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}

class _SplashPatternPainter extends CustomPainter {
  const _SplashPatternPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primary).withValues(
        alpha: isDark ? 0.035 : 0.045,
      )
      ..strokeWidth = 1;
    const gap = 36.0;
    for (var x = 0.0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
