import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';

class ReceiptScannerPage extends StatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  State<ReceiptScannerPage> createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends State<ReceiptScannerPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitializing = true;
  String? _errorMessage;
  bool _flashOn = false;
  bool _isCapturing = false;

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

    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = 'Camera permission is required to scan receipts.';
        _isInitializing = false;
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No camera available on this device.';
          _isInitializing = false;
        });
        return;
      }

      final backCamera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _controller = controller;
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera error: ${e.description}';
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final next = !_flashOn;
    await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    setState(() => _flashOn = next);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      if (mounted) {
        context.push('/scanner/crop', extra: file.path);
      }
    } on CameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: ${e.description}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      context.push('/scanner/crop', extra: picked.path);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanLineController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or loading/error placeholder
          Positioned.fill(
            child: _buildCameraPreview(),
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
                    onTap: () => context.safePop(AppRoutes.dashboard),
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
                      onTap: _toggleFlash,
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
                      onTap: _capture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isCapturing
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF2563EB),
                                  ),
                                )
                              : Container(
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
                      onTap: _pickFromGallery,
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

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final error = _errorMessage;
    if (error != null) {
      return Container(
        color: Colors.black,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _initCamera,
                child: Text(
                  'Retry',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return CameraPreview(controller);
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
