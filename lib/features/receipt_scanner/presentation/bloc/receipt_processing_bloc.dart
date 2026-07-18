import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import 'receipt_processing_event.dart';
import 'receipt_processing_state.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/services/receipt_text_classifier.dart';
import '../../../expenses/data/datasources/expense_local_data_source.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

@injectable
class ReceiptProcessingBloc
    extends Bloc<ReceiptProcessingEvent, ReceiptProcessingState> {
  final Dio _dio;
  final ExpenseLocalDataSource _expenseLocal;
  final AuthLocalDataSource _authLocal;

  ReceiptProcessingBloc(
    @Named('dio') this._dio,
    this._expenseLocal,
    this._authLocal,
  ) : super(const ProcessingInitial()) {
    on<StartReceiptProcessing>(_onStart);
    on<RunOcrExtraction>(_onRunOcr);
    on<RunAiCategorization>(_onRunAiCategorization);
  }

  Future<bool> _isPremium() async {
    // Check backend first (source of truth)
    try {
      final resp = await _dio.get('/api/subscription/usage');
      if (resp.statusCode == 200) {
        final data = resp.data['data'] as Map<String, dynamic>?;
        if (data != null && data['is_premium'] == true) return true;
      }
    } catch (_) {}
    // Fallback to cached user
    try {
      final user = await _authLocal.getCachedUser();
      return user?.subscriptionStatus == AppConstants.planPremium;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onStart(
    StartReceiptProcessing event,
    Emitter<ReceiptProcessingState> emit,
  ) async {
    // ── FIXED LIMITS: Backend + local pre-check before any AI cost ──
    // Free: 10 scans/month, Premium: 300 scans/month (manual unlimited, no AI)
    try {
      final isPremium = await _isPremium();
      int backendScans = 0;
      try {
        final resp = await _dio.get('/api/subscription/usage');
        if (resp.statusCode == 200) {
          final data = resp.data['data'] as Map<String, dynamic>?;
          backendScans = (data?['scans']?['used'] as int?) ?? (data?['scans_used'] as int? ?? 0);
        }
      } catch (_) {}
      final localScans = await _expenseLocal.getMonthlyScannedCount();
      final monthlyScans = backendScans > localScans ? backendScans : localScans;
      final limit = isPremium ? AppConstants.premiumMonthlyScans : AppConstants.freeMonthlyScans;
      if (monthlyScans >= limit) {
        emit(ProcessingLimitExceeded(
          message: isPremium
              ? 'Monthly AI scan limit reached ($limit/month for premium). Resets next month.'
              : 'Monthly receipt scan limit reached ($limit/month for free). Upgrade to premium for ${AppConstants.premiumMonthlyScans} scans/month.',
          code: 'SCAN_LIMIT_EXCEEDED',
          used: monthlyScans,
          limit: limit,
          resetsAt: _getNextMonthReset(),
        ));
        return;
      }
    } catch (_) {
      // If check fails, continue to backend enforcement (source of truth will block with 429)
    }

    // ── Step 1: Compressing / preparing image ──────────────────────────
    emit(const ProcessingStep(
      stepIndex: 1,
      totalSteps: 6,
      label: 'Preparing image...',
    ));

    String extractedText = '';
    try {
      // ── Step 2: Extracting text locally ──────────────────────────────
      emit(const ProcessingStep(
        stepIndex: 2,
        totalSteps: 6,
        label: 'Extracting text locally...',
      ));

      TextRecognizer? textRecognizer;
      try {
        final inputImage = InputImage.fromFilePath(event.imagePath);
        textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final recognizedText = await textRecognizer.processImage(inputImage);
        extractedText = recognizedText.text.trim();
      } catch (_) {
        emit(const ProcessingError(
          'We could not read this image. Please use a clear photo of a receipt or bill.',
        ));
        return;
      } finally {
        await textRecognizer?.close();
      }

      if (!ReceiptTextClassifier.isLikelyReceipt(extractedText)) {
        emit(const ProcessingError(
          'This image does not appear to be a receipt or bill. Please capture the full receipt in good lighting.',
        ));
        return;
      }

      // ── Step 3: Uploading to server ──────────────────────────────────
      emit(const ProcessingStep(
        stepIndex: 3,
        totalSteps: 6,
        label: 'Uploading receipt...',
      ));

      final formDataMap = <String, dynamic>{
        'image': await MultipartFile.fromFile(
          event.imagePath,
          filename: 'receipt.jpg',
        ),
      };

      formDataMap['ocr_text'] = extractedText;

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        '/api/ai/process-receipt',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      // ── Step 4: AI analyzing the image ───────────────────────────────
      emit(const ProcessingStep(
        stepIndex: 4,
        totalSteps: 6,
        label: 'AI analyzing receipt...',
      ));

      // Small delay so the user sees this step
      await Future<void>.delayed(const Duration(milliseconds: 400));

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;

        if (data['is_receipt'] == false) {
          emit(const ProcessingError(
            'This image does not appear to be a receipt or bill. Please capture a clear receipt image.',
          ));
          return;
        }

        // ── Step 5: Extracting data ──────────────────────────────────
        emit(const ProcessingStep(
          stepIndex: 5,
          totalSteps: 6,
          label: 'Extracting expense data...',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 300));

        final vendor = data['vendor'] as String? ?? 'Unknown';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final date = data['date'] as String? ?? '';
        final category = data['category'] as String? ?? 'Other';
        final categoryType = data['category_type'] as String? ?? 'business';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.5;
        final explanation = data['explanation'] as String? ?? '';
        final currency = data['currency'] as String? ?? 'USD';
        final items = data['items'] as List<dynamic>? ?? [];
        final paymentMethod = data['payment_method'] as String?;
        final taxAmount = (data['tax_amount'] as num?)?.toDouble() ?? 0.0;
        final receiptUrl = data['receipt_url'] as String? ?? event.imagePath;
        final isDuplicate = data['is_duplicate'] as bool? ?? false;
        final duplicateReason = data['duplicate_reason'] as String?;
        final documentType = data['document_type'] as String? ?? 'receipt';
        final receiptNumber = data['receipt_number'] as String?;

        // ── Step 6: Categorizing ──────────────────────────────────────
        emit(const ProcessingStep(
          stepIndex: 6,
          totalSteps: 6,
          label: 'Finalizing category...',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 400));

        emit(ProcessingSuccess(
          vendor: vendor,
          amount: amount,
          date: date,
          currency: currency,
          category: category,
          categoryType: categoryType,
          confidence: confidence,
          explanation: explanation,
          items: items,
          paymentMethod: paymentMethod,
          taxAmount: taxAmount,
          receiptUrl: receiptUrl,
          isDuplicate: isDuplicate,
          duplicateReason: duplicateReason,
          documentType: documentType,
          receiptNumber: receiptNumber,
        ));
      } else {
        emit(ProcessingError(
          response.data['message'] ?? 'Failed to process receipt',
        ));
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final statusCode = e.response?.statusCode;

      // ── FIXED LIMITS: Handle 429 scan limit ──
      if (statusCode == 429) {
        final dataMap = responseData is Map<String, dynamic> ? responseData : null;
        final code = dataMap?['code'] as String? ?? 'SCAN_LIMIT_EXCEEDED';
        final message = dataMap?['message'] as String? ??
            e.response?.data?['message'] ??
            e.message ??
            'Monthly scan limit reached';

        final usage = dataMap?['data'] as Map<String, dynamic>?;
        final used = (usage?['scans']?['used'] as int?) ??
            (usage?['scans_used'] as int?) ??
            AppConstants.freeMonthlyScans;
        final limit = (usage?['scans']?['limit'] as int?) ??
            (usage?['scans_limit'] as int?) ??
            AppConstants.freeMonthlyScans;

        emit(ProcessingLimitExceeded(
          message: message,
          code: code,
          used: used,
          limit: limit,
          resetsAt: (usage?['resets_at'] as String?) ?? _getNextMonthReset(),
          usage: usage,
        ));
        return;
      }

      final msg =
          responseData is Map ? responseData['message'] as String? : null;
      emit(ProcessingError(msg ?? e.message ?? 'Connection error'));
    } catch (e) {
      emit(ProcessingError(e.toString()));
    }
  }

  String _getNextMonthReset() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return nextMonth.toIso8601String();
  }

  Future<void> _onRunOcr(
    RunOcrExtraction event,
    Emitter<ReceiptProcessingState> emit,
  ) async {
    add(StartReceiptProcessing(event.imagePath));
  }

  Future<void> _onRunAiCategorization(
    RunAiCategorization event,
    Emitter<ReceiptProcessingState> emit,
  ) async {
    emit(const ProcessingStep(
      stepIndex: 3,
      totalSteps: 5,
      label: 'AI categorizing...',
    ));
    try {
      final response = await _dio.post('/api/ai/categorize', data: {
        'vendor': event.vendor,
        'amount': event.amount,
        'date': event.date,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        emit(AiCategorizationCompleted(
          vendor: event.vendor,
          amount: event.amount,
          date: event.date,
          category: data['category'] ?? 'Other',
          categoryType: data['category_type'] ?? 'business',
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
          explanation: data['explanation'] ?? '',
        ));
      }
    } catch (e) {
      emit(ProcessingError(e.toString()));
    }
  }
}
