import 'dart:io';
import 'package:camera/camera.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/di/injection.dart';
import 'package:billlens/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../expenses/data/datasources/expense_local_data_source.dart';

/// Modern receipt scanner with box-only capture
/// Only the portion inside the scan frame is saved, not full screen
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
  int _cameraSession = 0;
  bool _isClosing = false;
  bool _isDisposing = false;

  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;
  late final AnimationController _pulseController;

  // Usage for banner
  int _scansUsed = 0;
  int _scansLimit = AppConstants.freeMonthlyScans;
  bool _isPremium = false;

  // Box dimensions (logical pixels)
  static const double _frameWidth = 300;
  static const double _frameHeight = 400;

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    int backendScans = 0;
    int backendLimit = AppConstants.freeMonthlyScans;
    bool backendPremium = false;

    try {
      final dio = getIt<Dio>(instanceName: 'dio');
      final resp = await dio.get('/api/subscription/usage');
      if (resp.statusCode == 200) {
        final data = resp.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          backendPremium = data['is_premium'] as bool? ?? false;
          backendScans = (data['scans']?['used'] as int?) ??
              (data['scans_used'] as int? ?? 0);
          backendLimit = (data['scans']?['limit'] as int?) ??
              (data['scans_limit'] as int? ?? 10);
          if (mounted) {
            setState(() {
              _isPremium = backendPremium;
              _scansUsed = backendScans;
              _scansLimit = backendLimit;
            });
          }
        }
      }
    } catch (_) {}

    // Also check local pending to prevent bypass - take max of backend and local
    try {
      final local = getIt<ExpenseLocalDataSource>();
      final usage = await local.getMonthlyUsage();
      final localScans = usage['scanned'] ?? 0;
      if (mounted) {
        final maxScans = backendScans > localScans ? backendScans : localScans;
        if (maxScans != backendScans) {
          setState(() {
            _scansUsed = maxScans;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _initCamera() async {
    await _releaseCamera();
    if (!mounted) return;
    final session = ++_cameraSession;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    final status = await Permission.camera.request();
    if (!mounted || session != _cameraSession) return;
    if (!status.isGranted) {
      setState(() {
        _errorMessage = 'Camera permission is required to scan receipts.';
        _isInitializing = false;
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (!mounted || session != _cameraSession) return;
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
      if (!mounted || _controller != controller || session != _cameraSession) {
        await controller.dispose();
        return;
      }
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

  Future<void> _releaseCamera() async {
    _cameraSession++;
    final controller = _controller;
    if (controller == null) return;

    if (mounted && !_isDisposing) {
      setState(() {
        _controller = null;
        _flashOn = false;
      });
      await WidgetsBinding.instance.endOfFrame;
    } else {
      _controller = null;
      _flashOn = false;
    }

    try {
      await controller.dispose();
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await _releaseCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (ModalRoute.of(context)?.isCurrent != true) return;
      final controller = _controller;
      if (controller == null || !controller.value.isInitialized) {
        await _initCamera();
      }
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final next = !_flashOn;
    await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    setState(() => _flashOn = next);
  }

  /// Crops captured image to only the box area (not full screen)
  /// Uses center crop with box aspect ratio, approximating the overlay box
  Future<String> _cropToBox(String originalPath, Size screenSize) async {
    try {
      final bytes = await File(originalPath).readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return originalPath;

      final imgWidth = originalImage.width;
      final imgHeight = originalImage.height;

      // Box dimensions on screen (logical)
      const boxWidth = _frameWidth;
      const boxHeight = _frameHeight;

      // Calculate relative box rect on screen (centered)
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;
      final boxLeft = (screenWidth - boxWidth) / 2;
      final boxTop = (screenHeight - boxHeight) / 2;

      // Relative percentages
      final relLeft = boxLeft / screenWidth;
      final relTop = boxTop / screenHeight;
      final relWidth = boxWidth / screenWidth;
      final relHeight = boxHeight / screenHeight;

      // Map to image coordinates
      // Camera preview is scaled with BoxFit.cover, so we need to account for that
      // Simplified: use center crop with box aspect ratio, 85% of image
      final boxAspect = boxWidth / boxHeight; // 0.75
      final imgAspect = imgWidth / imgHeight;

      int cropWidth, cropHeight, cropX, cropY;

      if (imgAspect > boxAspect) {
        // Image wider than box - crop height 85%, width based on box aspect
        cropHeight = (imgHeight * 0.85).toInt();
        cropWidth = (cropHeight * boxAspect).toInt();
        cropX = ((imgWidth - cropWidth) / 2).toInt();
        cropY = ((imgHeight - cropHeight) / 2).toInt();
      } else {
        // Image taller than box - crop width 85%
        cropWidth = (imgWidth * 0.85).toInt();
        cropHeight = (cropWidth / boxAspect).toInt();
        cropX = ((imgWidth - cropWidth) / 2).toInt();
        cropY = ((imgHeight - cropHeight) / 2).toInt();
      }

      // More precise mapping using relative box position
      // Adjust to use relative positioning for better accuracy
      final preciseX = (relLeft * imgWidth).toInt().clamp(0, imgWidth - 100);
      final preciseY = (relTop * imgHeight).toInt().clamp(0, imgHeight - 100);
      final preciseW = (relWidth * imgWidth).toInt().clamp(100, imgWidth);
      final preciseH = (relHeight * imgHeight).toInt().clamp(100, imgHeight);

      // Use average of center crop and precise mapping for best result
      // For now, use precise mapping but ensure it doesn't exceed image bounds
      final finalX = ((preciseX + cropX) / 2).toInt().clamp(0, imgWidth - 100);
      final finalY = ((preciseY + cropY) / 2).toInt().clamp(0, imgHeight - 100);
      final finalW =
          ((preciseW + cropWidth) / 2).toInt().clamp(100, imgWidth - finalX);
      final finalH =
          ((preciseH + cropHeight) / 2).toInt().clamp(100, imgHeight - finalY);

      final cropped = img.copyCrop(
        originalImage,
        x: finalX,
        y: finalY,
        width: finalW,
        height: finalH,
      );

      // Save cropped image to temp file
      final tempDir = await getTemporaryDirectory();
      final croppedPath = p.join(
          tempDir.path, 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final croppedBytes = img.encodeJpg(cropped, quality: 92);
      await File(croppedPath).writeAsBytes(croppedBytes);

      return croppedPath;
    } catch (e) {
      // If crop fails, return original
      return originalPath;
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    // Check limit before capture
    if (!_isPremium && _scansUsed >= _scansLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Scan limit reached ($_scansUsed/$_scansLimit). Upgrade to premium.'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Upgrade',
            textColor: Colors.white,
            onPressed: () => context.push(AppRoutes.subscription),
          ),
        ),
      );
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      final screenSize = MediaQuery.of(context).size;

      // Crop to box area only (not full screen)
      final croppedPath = await _cropToBox(file.path, screenSize);

      await _releaseCamera();
      if (mounted) {
        await context.push(AppRoutes.receiptCrop, extra: croppedPath);
        if (mounted) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            await _initCamera();
            _loadUsage(); // Refresh usage after scan
          }
        }
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
    await _releaseCamera();
    if (!mounted) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      await context.push(AppRoutes.receiptCrop, extra: picked.path);
      if (mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (mounted) await _initCamera();
      }
    } else if (mounted) {
      await _initCamera();
    }
  }

  Future<void> _closeScanner() async {
    if (_isClosing) return;
    _isClosing = true;
    await _releaseCamera();
    if (mounted) context.safePop(AppRoutes.dashboard);
  }

  @override
  void dispose() {
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _scanLineController.dispose();
    _pulseController.dispose();
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.dispose().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closeScanner();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: _buildCameraPreview()),
            Positioned.fill(child: _ScanOverlayBox()),
            Center(
                child: _ImprovedScanFrame(
                    scanLineAnimation: _scanLineAnimation,
                    pulseAnimation: _pulseController)),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context),
                  const Spacer(),
                  _buildHintAndUsage(context),
                  const SizedBox(height: 16),
                  _buildBottomControls(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final remaining = (_scansLimit - _scansUsed).clamp(0, _scansLimit);
    final isExhausted = !_isPremium && remaining == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _closeScanner,
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          Column(
            children: [
              Text('Scan Receipt',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text('Only box area will be captured',
                  style:
                      GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
            ],
          ),
          Row(
            children: [
              if (!_isPremium)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExhausted
                        ? AppColors.error.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.document_scanner_rounded,
                          size: 14,
                          color: isExhausted ? Colors.white : Colors.white70),
                      const SizedBox(width: 4),
                      Text('$_scansUsed/$_scansLimit',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: _toggleFlash,
                  icon: Icon(
                      _flashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      color: _flashOn ? Colors.amber : Colors.white,
                      size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHintAndUsage(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.crop_free_rounded,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                  'Position receipt inside the frame. Only this area will be captured.',
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (!_isPremium && _scansUsed >= _scansLimit) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text('Limit reached ($_scansLimit/month). ',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.subscription),
                  child: Text('Upgrade',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.95)
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            onTap: _pickFromGallery,
          ),
          _buildCaptureButton(),
          _buildControlButton(
            icon: Icons.edit_note_rounded,
            label: 'Manual',
            onTap: () => context.push(AppRoutes.addExpense),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _capture,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
          child: _isCapturing
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                      strokeWidth: 3, color: AppColors.primary),
                )
              : Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 28),
                ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text('Initializing camera...',
                  style:
                      GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
            ],
          ),
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.videocam_off_rounded,
                    color: Colors.white70, size: 40),
              ),
              const SizedBox(height: 20),
              Text(error,
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.outfit(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Retry',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
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

/// Dark overlay with transparent box in center (only box area will be captured)
class _ScanOverlayBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _OverlayPainter(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameWidth = 300.0;
    const frameHeight = 400.0;
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2;

    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.65);

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final framePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
          const Radius.circular(16)));

    final overlayPath =
        Path.combine(PathOperation.difference, backgroundPath, framePath);
    canvas.drawPath(overlayPath, overlayPaint);

    // Subtle border around frame
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
            const Radius.circular(16)),
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Improved scan frame with glowing corners and animated scan line
class _ImprovedScanFrame extends StatelessWidget {
  final Animation<double> scanLineAnimation;
  final AnimationController pulseAnimation;

  const _ImprovedScanFrame(
      {required this.scanLineAnimation, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    const frameWidth = 300.0;
    const frameHeight = 400.0;
    const cornerSize = 32.0;
    const cornerThickness = 4.5;

    return SizedBox(
      width: frameWidth,
      height: frameHeight,
      child: Stack(
        children: [
          // Corner brackets
          Positioned(
              top: 0,
              left: 0,
              child: _CornerBracket(
                  corner: _CornerType.topLeft,
                  size: cornerSize,
                  thickness: cornerThickness)),
          Positioned(
              top: 0,
              right: 0,
              child: _CornerBracket(
                  corner: _CornerType.topRight,
                  size: cornerSize,
                  thickness: cornerThickness)),
          Positioned(
              bottom: 0,
              left: 0,
              child: _CornerBracket(
                  corner: _CornerType.bottomLeft,
                  size: cornerSize,
                  thickness: cornerThickness)),
          Positioned(
              bottom: 0,
              right: 0,
              child: _CornerBracket(
                  corner: _CornerType.bottomRight,
                  size: cornerSize,
                  thickness: cornerThickness)),

          // Center crosshair hint
          Center(
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, _) {
                return Opacity(
                  opacity: 0.3 + (pulseAnimation.value * 0.4),
                  child: Icon(Icons.crop_free_rounded,
                      color: Colors.white.withValues(alpha: 0.6), size: 48),
                );
              },
            ),
          ),

          // Animated scan line with glow
          AnimatedBuilder(
            animation: scanLineAnimation,
            builder: (context, _) {
              final top = scanLineAnimation.value * (frameHeight - 8);
              return Positioned(
                top: top,
                left: 8,
                right: 8,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.9),
                        const Color(0xFF10B981),
                        AppColors.primary.withValues(alpha: 0.9),
                        Colors.transparent
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1)
                    ],
                  ),
                ),
              );
            },
          ),

          // Top label inside frame
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('AUTO-CROP TO BOX',
                        style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5)),
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

class _CornerBracket extends StatelessWidget {
  final _CornerType corner;
  final double size;
  final double thickness;

  const _CornerBracket(
      {required this.corner, required this.size, required this.thickness});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EnhancedCornerPainter(thickness: thickness, corner: corner),
      ),
    );
  }
}

enum _CornerType { topLeft, topRight, bottomLeft, bottomRight }

class _EnhancedCornerPainter extends CustomPainter {
  final double thickness;
  final _CornerType corner;

  _EnhancedCornerPainter({required this.thickness, required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness + 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    switch (corner) {
      case _CornerType.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case _CornerType.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case _CornerType.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case _CornerType.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
