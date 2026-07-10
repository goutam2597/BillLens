import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();
  @override
  List<Object?> get props => [];
}

class GenerateReport extends ReportsEvent {
  final String reportType; // 'monthly', 'tax', 'business', 'category', 'client'
  final DateTime? startDate;
  final DateTime? endDate;

  const GenerateReport({
    required this.reportType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [reportType, startDate, endDate];
}

class ExportPdfReport extends ReportsEvent {}

class ExportCsvReport extends ReportsEvent {}
