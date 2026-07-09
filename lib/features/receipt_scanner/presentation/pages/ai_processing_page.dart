import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AI Processing Page
// ─────────────────────────────────────────────────────────────────────────────
class AiProcessingPage extends StatefulWidget {
  const AiProcessingPage({super.key});

  @override
  State<AiProcessingPage> createState() => _AiProcessingPageState();
}

class _AiProcessingPageState extends State<AiProcessingPage>
    with TickerProviderStateMixin {
  // Processing steps
  static const _steps = [
    'Image Processing',
    'OCR Reading',
    'Extracting Vendor',
    'Extracting Amount',
    'AI Categorization',
  ];

  // 0 = pending, 1 = active, 2 = done
  final List<int> _stepStates = List.filled(5, 0);
  int _currentStep = 0;
  Timer? _timer;

  // Gradient animation controller
  late final AnimationController _rotationController;
  // Pulse animation controller
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Kick off the first step immediately
    _advanceStep();
  }

  void _advanceStep() {
    if (!mounted) return;
    if (_currentStep >= _steps.length) return;

    // Mark current step as active
    setState(() => _stepStates[_currentStep] = 1);

    _timer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _stepStates[_currentStep] = 2);
      _currentStep++;

      if (_currentStep < _steps.length) {
        _advanceStep();
      } else {
        // All done – navigate after a brief pause
        Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/scanner/result');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated gradient orb ───────────────────────────────
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            startAngle: 0,
                            endAngle: 2 * 3.14159265,
                            transform: GradientRotation(
                                _rotationController.value * 2 * 3.14159265),
                            colors: const [
                              Color(0xFF2563EB),
                              Color(0xFF10B981),
                              Color(0xFF7C3AED),
                              Color(0xFF2563EB),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.35),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.document_scanner_outlined,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 36),

                // ── Title ───────────────────────────────────────────────
                Text(
                  'Analyzing Receipt...',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Subtitle ────────────────────────────────────────────
                Text(
                  'Our AI is extracting your expense data',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Steps list ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: List.generate(_steps.length, (index) {
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: _stepStates[index] > 0 ? 1.0 : 0.3,
                        child: _StepRow(
                          label: _steps[index],
                          state: _stepStates[index],
                          isLast: index == _steps.length - 1,
                        ),
                      );
                    }),
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

// ─────────────────────────────────────────────────────────────────────────────
// Step Row Widget
// ─────────────────────────────────────────────────────────────────────────────
class _StepRow extends StatelessWidget {
  final String label;
  final int state; // 0 = pending, 1 = active, 2 = done
  final bool isLast;

  const _StepRow({
    required this.label,
    required this.state,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          // Status icon
          _StepIcon(state: state),
          const SizedBox(width: 14),
          // Label
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: state == 2 ? FontWeight.w600 : FontWeight.w400,
                color: state == 2
                    ? const Color(0xFF0F172A)
                    : state == 1
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF94A3B8),
              ),
            ),
          ),
          // Duration badge when done
          if (state == 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step Icon Widget
// ─────────────────────────────────────────────────────────────────────────────
class _StepIcon extends StatelessWidget {
  final int state;

  const _StepIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state == 2) {
      // Done – green checkmark
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    } else if (state == 1) {
      // Active – spinner
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
          backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
        ),
      );
    } else {
      // Pending – gray circle
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
        ),
      );
    }
  }
}
