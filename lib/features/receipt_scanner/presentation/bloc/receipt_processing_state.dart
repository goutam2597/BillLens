import 'package:equatable/equatable.dart';

abstract class ReceiptProcessingState extends Equatable {
  const ReceiptProcessingState();
  @override
  List<Object?> get props => [];
}

class ProcessingInitial extends ReceiptProcessingState {
  const ProcessingInitial();
}

/// Currently executing step with real progress.
class ProcessingStep extends ReceiptProcessingState {
  final int stepIndex; // 1-based
  final int totalSteps;
  final String label;

  const ProcessingStep({
    required this.stepIndex,
    required this.totalSteps,
    required this.label,
  });

  @override
  List<Object> get props => [stepIndex, totalSteps, label];
}

/// Deprecated — kept for backward compat with any old listeners.
class ProcessingLoading extends ReceiptProcessingState {
  final String currentStep;
  const ProcessingLoading({this.currentStep = 'Starting...'});
  @override
  List<Object> get props => [currentStep];
}

class OcrCompleted extends ReceiptProcessingState {
  final String vendor;
  final double amount;
  final String date;
  const OcrCompleted({required this.vendor, required this.amount, required this.date});
  @override
  List<Object> get props => [vendor, amount, date];
}

class AiCategorizationCompleted extends ReceiptProcessingState {
  final String vendor;
  final double amount;
  final String date;
  final String category;
  final String categoryType;
  final double confidence;
  final String explanation;
  const AiCategorizationCompleted({
    required this.vendor,
    required this.amount,
    required this.date,
    required this.category,
    required this.categoryType,
    required this.confidence,
    required this.explanation,
  });
  @override
  List<Object> get props => [vendor, amount, date, category, categoryType, confidence, explanation];
}

class ProcessingSuccess extends ReceiptProcessingState {
  final String vendor;
  final double amount;
  final String date;
  final String currency;
  final String category;
  final String categoryType;
  final double confidence;
  final String explanation;
  final List<dynamic> items;
  final String? paymentMethod;
  final double taxAmount;
  final String receiptUrl;
  final bool isDuplicate;
  final String? duplicateReason;
  final String documentType;
  final String? receiptNumber;

  const ProcessingSuccess({
    required this.vendor,
    required this.amount,
    required this.date,
    this.currency = 'USD',
    required this.category,
    required this.categoryType,
    required this.confidence,
    required this.explanation,
    this.items = const [],
    this.paymentMethod,
    this.taxAmount = 0,
    required this.receiptUrl,
    this.isDuplicate = false,
    this.duplicateReason,
    this.documentType = 'receipt',
    this.receiptNumber,
  });

  @override
  List<Object?> get props => [
        vendor, amount, date, currency, category, categoryType,
        confidence, explanation, items, paymentMethod, taxAmount, receiptUrl,
        isDuplicate, duplicateReason, documentType, receiptNumber,
      ];
}

class ProcessingError extends ReceiptProcessingState {
  final String message;
  const ProcessingError(this.message);
  @override
  List<Object> get props => [message];
}

/// FIXED LIMITS: Emitted when free user hits scan limit
class ProcessingLimitExceeded extends ReceiptProcessingState {
  final String message;
  final String code; // SCAN_LIMIT_EXCEEDED
  final int used;
  final int limit;
  final String resetsAt;
  final Map<String, dynamic>? usage;

  const ProcessingLimitExceeded({
    required this.message,
    required this.code,
    required this.used,
    required this.limit,
    required this.resetsAt,
    this.usage,
  });

  int get remaining => 0;

  @override
  List<Object?> get props => [message, code, used, limit, resetsAt, usage];
}
