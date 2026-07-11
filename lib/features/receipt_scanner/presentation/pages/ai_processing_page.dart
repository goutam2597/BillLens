import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/receipt_processing_bloc.dart';
import '../bloc/receipt_processing_event.dart';
import '../bloc/receipt_processing_state.dart';

class AiProcessingPage extends StatefulWidget {
  final String imagePath;

  const AiProcessingPage({super.key, required this.imagePath});

  @override
  State<AiProcessingPage> createState() => _AiProcessingPageState();
}

class _AiProcessingPageState extends State<AiProcessingPage>
    with TickerProviderStateMixin {
  late final ReceiptProcessingBloc _bloc;
  late final AnimationController _entryController;
  late final AnimationController _scanController;

  int _currentStep = 0;
  static const int _totalSteps = 6;
  static const _stepLabels = [
    'Prepare image',
    'Read receipt text',
    'Secure upload',
    'Analyze details',
    'Extract expense data',
    'Assign category',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ReceiptProcessingBloc>()
      ..add(StartReceiptProcessing(widget.imagePath));
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _retry() {
    setState(() => _currentStep = 0);
    _scanController.repeat(reverse: true);
    _bloc.add(StartReceiptProcessing(widget.imagePath));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _scanController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ReceiptProcessingBloc, ReceiptProcessingState>(
        listener: (context, state) {
          if (state is ProcessingStep) {
            setState(() {
              _currentStep = (state.stepIndex - 1).clamp(0, _totalSteps - 1);
            });
          } else if (state is ProcessingSuccess) {
            _scanController.stop();
            context.pushReplacement(AppRoutes.receiptResult, extra: state);
          } else if (state is ProcessingError) {
            _scanController.stop();
          }
        },
        builder: (context, state) {
          final hasError = state is ProcessingError;
          final progress = hasError
              ? _currentStep / _totalSteps
              : ((_currentStep + 1) / _totalSteps).clamp(0.0, 1.0);
          final currentLabel = state is ProcessingStep
              ? state.label
              : hasError
                  ? 'We could not read this receipt'
                  : 'Preparing your receipt';

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            appBar: AppPageBar(
              title: 'Receipt analysis',
              leading: IconButton(
                tooltip: 'Close analysis',
                onPressed: () => context.go(AppRoutes.receiptScanner),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            body: SafeArea(
              top: false,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryController,
                  curve: Curves.easeOut,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReceiptPreview(
                            imagePath: widget.imagePath,
                            scanAnimation: _scanController,
                            hasError: hasError,
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: hasError
                                ? _FailurePanel(
                                    key: const ValueKey('failure'),
                                    message: state.message,
                                    onRetake: () =>
                                        context.go(AppRoutes.receiptScanner),
                                    onRetry: _retry,
                                    onClose: () =>
                                        context.go(AppRoutes.dashboard),
                                  )
                                : _ProgressPanel(
                                    key: const ValueKey('progress'),
                                    currentLabel: currentLabel,
                                    currentStep: _currentStep,
                                    progress: progress,
                                    colorScheme: colorScheme,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({
    required this.imagePath,
    required this.scanAnimation,
    required this.hasError,
  });

  final String imagePath;
  final Animation<double> scanAnimation;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        width: 190,
        height: 230,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 72,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            if (!hasError)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedBuilder(
                    animation: scanAnimation,
                    builder: (context, _) => Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: scanAnimation.value * 226,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.65),
                                  blurRadius: 14,
                                  spreadRadius: 3,
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
            Positioned(
              right: -14,
              bottom: -14,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasError ? colorScheme.error : AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surfaceContainerLowest,
                    width: 5,
                  ),
                ),
                child: Icon(
                  hasError ? Icons.priority_high_rounded : Icons.auto_awesome,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    super.key,
    required this.currentLabel,
    required this.currentStep,
    required this.progress,
    required this.colorScheme,
  });

  final String currentLabel;
  final int currentStep;
  final double progress;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          currentLabel,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'BillLens is organizing the important details for you.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 14,
            height: 1.45,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        AppGroupedSurface(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Analysis progress',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: progress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 22),
              ...List.generate(_AiProcessingPageState._stepLabels.length,
                  (index) {
                final complete = index < currentStep;
                final active = index == currentStep;
                final isLast =
                    index == _AiProcessingPageState._stepLabels.length - 1;
                return _TimelineStep(
                  label: _AiProcessingPageState._stepLabels[index],
                  complete: complete,
                  active: active,
                  isLast: isLast,
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Your receipt is processed securely',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.complete,
    required this.active,
    required this.isLast,
  });

  final String label;
  final bool complete;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final markerColor = complete
        ? AppColors.accent
        : active
            ? colorScheme.primary
            : colorScheme.outlineVariant;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color:
                        complete || active ? markerColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: markerColor, width: 1.5),
                  ),
                  child: complete
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : active
                          ? const Center(
                              child: SizedBox(
                                width: 6,
                                height: 6,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            )
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: complete
                          ? AppColors.accent.withValues(alpha: 0.45)
                          : colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 17),
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: complete || active
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FailurePanel extends StatelessWidget {
  const _FailurePanel({
    super.key,
    required this.message,
    required this.onRetake,
    required this.onRetry,
    required this.onClose,
  });

  final String message;
  final VoidCallback onRetake;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'We could not read this receipt',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 14,
            height: 1.5,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        AppGroupedSurface(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Use a clear, well-lit photo with the full receipt visible.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    height: 1.45,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Retake',
                height: 50,
                onPressed: onRetake,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Try again',
                height: 50,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
