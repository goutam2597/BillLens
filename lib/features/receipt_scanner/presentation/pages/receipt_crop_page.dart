import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReceiptCropPage extends StatefulWidget {
  const ReceiptCropPage({super.key});

  @override
  State<ReceiptCropPage> createState() => _ReceiptCropPageState();
}

class _ReceiptCropPageState extends State<ReceiptCropPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Crop Receipt',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Image area ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Gray placeholder
                    Container(
                      width: double.infinity,
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 80,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),

                    // Grid overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CropGridPainter(),
                      ),
                    ),

                    // Crop corners
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CropCornersPainter(),
                      ),
                    ),

                    // Overlay text
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Cropping tool coming soon – using full image',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom buttons ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rotate + Continue row
                Row(
                  children: [
                    // Rotate
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Rotate action (UI only)
                        },
                        icon: const Icon(
                          Icons.rotate_right_rounded,
                          size: 18,
                          color: Color(0xFF2563EB),
                        ),
                        label: Text(
                          'Rotate',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                              color: Color(0xFF2563EB), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Continue
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed('/scanner/processing'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Retake
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Retake',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Crop Grid Painter
// ─────────────────────────────────────────────────────────────────────────────
class _CropGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;

    // Vertical lines (thirds)
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines (thirds)
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropGridPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Crop Corners Painter
// ─────────────────────────────────────────────────────────────────────────────
class _CropCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 20.0;
    const armLength = 24.0;

    final corners = [
      // top-left
      [
        const Offset(margin, margin + armLength),
        const Offset(margin, margin),
        const Offset(margin + armLength, margin),
      ],
      // top-right
      [
        Offset(size.width - margin - armLength, margin),
        Offset(size.width - margin, margin),
        Offset(size.width - margin, margin + armLength),
      ],
      // bottom-left
      [
        Offset(margin, size.height - margin - armLength),
        Offset(margin, size.height - margin),
        Offset(margin + armLength, size.height - margin),
      ],
      // bottom-right
      [
        Offset(size.width - margin - armLength, size.height - margin),
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin, size.height - margin - armLength),
      ],
    ];

    for (final pts in corners) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropCornersPainter oldDelegate) => false;
}
