import 'package:equatable/equatable.dart';

abstract class ReceiptProcessingEvent extends Equatable {
  const ReceiptProcessingEvent();
  @override
  List<Object?> get props => [];
}

class StartReceiptProcessing extends ReceiptProcessingEvent {
  final String imagePath;

  const StartReceiptProcessing(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class RunOcrExtraction extends ReceiptProcessingEvent {
  final String imagePath;

  const RunOcrExtraction(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class RunAiCategorization extends ReceiptProcessingEvent {
  final String vendor;
  final double amount;
  final String date;

  const RunAiCategorization({
    required this.vendor,
    required this.amount,
    required this.date,
  });

  @override
  List<Object> get props => [vendor, amount, date];
}
