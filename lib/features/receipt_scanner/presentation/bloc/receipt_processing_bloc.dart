import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'receipt_processing_event.dart';
import 'receipt_processing_state.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/services/receipt_text_classifier.dart';

@injectable
class ReceiptProcessingBloc
    extends Bloc<ReceiptProcessingEvent, ReceiptProcessingState> {
  final Dio _dio;

  ReceiptProcessingBloc(@Named('dio') this._dio)
      : super(const ProcessingInitial()) {
    on<StartReceiptProcessing>(_onStart);
    on<RunOcrExtraction>(_onRunOcr);
    on<RunAiCategorization>(_onRunAiCategorization);
  }

  Future<void> _onStart(
    StartReceiptProcessing event,
    Emitter<ReceiptProcessingState> emit,
  ) async {
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
        ));
      } else {
        emit(ProcessingError(
          response.data['message'] ?? 'Failed to process receipt',
        ));
      }
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? e.message ?? 'Connection error';
      emit(ProcessingError(msg));
    } catch (e) {
      emit(ProcessingError(e.toString()));
    }
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
