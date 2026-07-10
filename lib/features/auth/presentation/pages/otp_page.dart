import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/widgets/app_widgets.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _otpLength = 6;
  static const String _dummyEmail = 'user@example.com';
  static const String _correctOtp = '123456';
  static const int _resendSeconds = 60;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  int _countdown = _resendSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    _countdown = _resendSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    final otp = _enteredOtp;
    if (otp.length < _otpLength) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Please enter the complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (otp == _correctOtp) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.dashboard);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Invalid OTP. Please try again.';
      });
      // Clear all boxes on wrong OTP
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  void _onBoxChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    // Clear error on change
    if (_hasError) setState(() => _hasError = false);
  }

  void _onBoxKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 2,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => context.safePop(AppRoutes.register),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Email icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Verify Email',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter the 6-digit code sent to your email',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              // Email display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _dummyEmail,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // OTP boxes
              Row(
                children: List.generate(
                  _otpLength,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _otpLength - 1 ? 0 : 8,
                      ),
                      child: _OtpBox(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        hasError: _hasError,
                        isDark: isDark,
                        onChanged: (v) => _onBoxChanged(v, index),
                        onKeyEvent: (e) => _onBoxKeyEvent(e, index),
                      ),
                    ),
                  ),
                ),
              ),

              // Error message
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _errorMessage,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 36),

              // Verify button
              PrimaryButton(
                text: 'Verify',
                isLoading: _isLoading,
                onPressed: _handleVerify,
                height: 54,
              ),

              const SizedBox(height: 28),

              // Resend OTP
              Center(
                child: _countdown > 0
                    ? RichText(
                        text: TextSpan(
                          text: "Resend OTP in ",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '${_countdown}s',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _startCountdown();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'OTP resent to $_dummyEmail',
                                style: GoogleFonts.outfit(fontSize: 14),
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Resend OTP',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              // Hint for demo
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Demo OTP: 123456',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── OTP box widget ─────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.isDark,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.error
        : (isDark ? AppColors.borderDark : AppColors.borderLight);
    final fillColor = hasError
        ? AppColors.error.withValues(alpha: 0.06)
        : (isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        height: 56,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
