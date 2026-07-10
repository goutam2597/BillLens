import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/widgets/app_widgets.dart';

class ReceiptCropPage extends StatefulWidget {
  final String? imagePath;

  const ReceiptCropPage({super.key, this.imagePath});

  @override
  State<ReceiptCropPage> createState() => _ReceiptCropPageState();
}

class _ReceiptCropPageState extends State<ReceiptCropPage> {
  late String? _imagePath;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
  }

  Future<void> _adjustReceipt() async {
    final imagePath = _imagePath;
    if (imagePath == null || _isEditing) return;

    setState(() => _isEditing = true);
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressQuality: 92,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Receipt',
            toolbarColor: const Color(0xFF2563EB),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF2563EB),
            lockAspectRatio: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Adjust Receipt',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );
      if (cropped != null && mounted) {
        setState(() => _imagePath = cropped.path);
      }
    } finally {
      if (mounted) setState(() => _isEditing = false);
    }
  }

  void _retake() => context.safePop(AppRoutes.receiptScanner);

  @override
  Widget build(BuildContext context) {
    final imagePath = _imagePath;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppPageBar(
        title: 'Crop Receipt',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.safePop(AppRoutes.receiptScanner),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(Icons.crop_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keep the receipt edges visible and remove the background.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      height: 1.35,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Material(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imagePath != null
                          ? Image.file(File(imagePath), fit: BoxFit.contain)
                          : const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  size: 64, color: Colors.white54),
                            ),
                    ),
                    const Positioned.fill(
                      child: IgnorePointer(
                          child: CustomPaint(painter: _CropCornersPainter())),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FilledButton.icon(
                        onPressed: imagePath == null ? null : _adjustReceipt,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              Colors.black.withValues(alpha: 0.45),
                          disabledForegroundColor: Colors.white54,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: _isEditing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.crop_rotate_rounded, size: 18),
                        label: const Text('Adjust & Rotate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Retake',
                      height: 52,
                      onPressed: _retake,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: 'Continue',
                      height: 52,
                      onPressed: imagePath == null
                          ? null
                          : () => context.push(
                                AppRoutes.aiProcessing,
                                extra: imagePath,
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Crop Corners Painter
// ─────────────────────────────────────────────────────────────────────────────
class _CropCornersPainter extends CustomPainter {
  const _CropCornersPainter();

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
