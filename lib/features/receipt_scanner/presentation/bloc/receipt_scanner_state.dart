import 'package:equatable/equatable.dart';

abstract class ReceiptScannerState extends Equatable {
  const ReceiptScannerState();
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ReceiptScannerState {
  const ScannerInitial();
}

class ScannerReady extends ReceiptScannerState {
  final bool flashOn;
  const ScannerReady({this.flashOn = false});
  @override
  List<Object> get props => [flashOn];
}

class ScannerCapturing extends ReceiptScannerState {
  const ScannerCapturing();
}

class ScannerImageCaptured extends ReceiptScannerState {
  final String imagePath;
  const ScannerImageCaptured(this.imagePath);
  @override
  List<Object> get props => [imagePath];
}

class ScannerError extends ReceiptScannerState {
  final String message;
  const ScannerError(this.message);
  @override
  List<Object> get props => [message];
}
