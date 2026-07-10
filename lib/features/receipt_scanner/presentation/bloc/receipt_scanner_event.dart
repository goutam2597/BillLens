import 'package:equatable/equatable.dart';

abstract class ReceiptScannerEvent extends Equatable {
  const ReceiptScannerEvent();
  @override
  List<Object?> get props => [];
}

class InitializeCamera extends ReceiptScannerEvent {}

class CaptureReceipt extends ReceiptScannerEvent {}

class PickReceiptFromGallery extends ReceiptScannerEvent {}

class ToggleFlash extends ReceiptScannerEvent {}
