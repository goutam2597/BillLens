import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:image_picker/image_picker.dart';

import 'receipt_scanner_event.dart';
import 'receipt_scanner_state.dart';

@injectable
class ReceiptScannerBloc extends Bloc<ReceiptScannerEvent, ReceiptScannerState> {
  final ImagePicker _picker;

  ReceiptScannerBloc() : _picker = ImagePicker(), super(const ScannerInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<CaptureReceipt>(_onCaptureReceipt);
    on<PickReceiptFromGallery>(_onPickFromGallery);
    on<ToggleFlash>(_onToggleFlash);
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<ReceiptScannerState> emit,
  ) async {
    emit(const ScannerReady());
  }

  Future<void> _onCaptureReceipt(
    CaptureReceipt event,
    Emitter<ReceiptScannerState> emit,
  ) async {
    emit(const ScannerCapturing());
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        emit(ScannerImageCaptured(photo.path));
      } else {
        emit(const ScannerReady());
      }
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  Future<void> _onPickFromGallery(
    PickReceiptFromGallery event,
    Emitter<ReceiptScannerState> emit,
  ) async {
    emit(const ScannerCapturing());
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (photo != null) {
        emit(ScannerImageCaptured(photo.path));
      } else {
        emit(const ScannerReady());
      }
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  Future<void> _onToggleFlash(
    ToggleFlash event,
    Emitter<ReceiptScannerState> emit,
  ) async {
    if (state is ScannerReady) {
      final current = state as ScannerReady;
      emit(ScannerReady(flashOn: !current.flashOn));
    }
  }
}
