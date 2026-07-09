import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  State<ReceiptScannerPage> createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends State<ReceiptScannerPage>
    with TickerProviderStateMixin {
  bool _flashOn = false;

  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview placeholder
          Positioned.fill(
            child: Container(color: Colors.black),
          ),

          // Darkened overlay outside the scan frame
          Positioned.fill(
            child: _ScanOverlay(),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'Scan Receipt',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scan frame + animated line
          Center(
            child: _AnimatedScanFrame(scanLineAnimation: _scanLineAnimation),
          ),

          // Hint text
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Position receipt within the frame',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.white60,
                  fontWeight: FontWeight.w400,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Flash toggle
                    GestureDetector(
                      onTap: () => setState(() => _flashOn = !_flashOn),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _flashOn ? Icons.flash_on : Icons.flash_off,
                          color: _flashOn ? Colors.amber : Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('/scanner/crop'),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Gallery button
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('/scanner/crop'),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 24,
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

// ─────────────────────────────────────────────────────────────────────────────
// Animated Scan Frame
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedScanFrame extends StatelessWidget {
  final Animation<double> scanLineAnimation;

  const _AnimatedScanFrame({required this.scanLineAnimation});

  @override
  Widget build(BuildContext context) {
    const frameWidth = 280.0;
    const frameHeight = 380.0;
    const cornerSize = 28.0;
    const cornerThickness = 4.0;

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: Stack(
        children: [
          // Top-left corner
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(cornerSize, cornerSize),
              painter: _CornerPainter(
                thickness: cornerThickness,
                corner: _CornerType.topLeft,
              ),
            ),
          ),
          // Top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(cornerSize, cornerSize),
              painter: _CornerPainter(
                thickness: cornerThickness,
                corner: _CornerType.topRight,
              ),
            ),
          ),
          // Bottom-left corner
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(cornerSize, cornerSize),
              painter: _CornerPainter(
                thickness: cornerThickness,
                corner: _CornerType.bottomLeft,
              ),
            ),
          ),
          // Bottom-right corner
          Positioned(
            bottom: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(cornerSize, cornerSize),
              painter: _CornerPainter(
                thickness: cornerThickness,
                corner: _CornerType.bottomRight,
              ),
            ),
          ),

          // Animated scan line
          AnimatedBuilder(
            animation: scanLineAnimation,
            builder: (context, _) {
              final top = scanLineAnimation.value * (frameHeight - 4);
              return Positioned(
                top: top,
                left: 12,
                right: 12,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF2563EB).withValues(alpha: 0.8),
                        const Color(0xFF10B981),
                        const Color(0xFF2563EB).withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Corner Painter
// ─────────────────────────────────────────────────────────────────────────────
enum _CornerType { topLeft, topRight, bottomLeft, bottomRight }

class _CornerPainter extends CustomPainter {
  final double thickness;
  final _CornerType corner;

  _CornerPainter({required this.thickness, required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    const r = 6.0;

    final path = Path();

    switch (corner) {
      case _CornerType.topLeft:
        path.moveTo(0, h);
        path.lineTo(0, r);
        path.arcToPoint(const Offset(r, 0),
            radius: const Radius.circular(r), clockwise: true);
        path.lineTo(w, 0);
        break;
      case _CornerType.topRight:
        path.moveTo(0, 0);
        path.lineTo(w - r, 0);
        path.arcToPoint(Offset(w, r),
            radius: const Radius.circular(r), clockwise: true);
        path.lineTo(w, h);
        break;
      case _CornerType.bottomLeft:
        path.moveTo(w, h);
        path.lineTo(r, h);
        path.arcToPoint(Offset(0, h - r),
            radius: const Radius.circular(r), clockwise: false);
        path.lineTo(0, 0);
        break;
      case _CornerType.bottomRight:
        path.moveTo(0, h);
        path.lineTo(w - r, h);
        path.arcToPoint(Offset(w, h - r),
            radius: const Radius.circular(r), clockwise: true);
        path.lineTo(w, 0);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan Overlay – darkens everything outside the scan frame
// ─────────────────────────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OverlayPainter());
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameWidth = 280.0;
    const frameHeight = 380.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: frameWidth,
        height: frameHeight,
      ),
      const Radius.circular(16),
    );

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(fullRect)
      ..addRRect(frameRect);

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) => false;
}
