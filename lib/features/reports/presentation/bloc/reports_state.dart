import 'package:equatable/equatable.dart';
import '../../../expenses/domain/entities/expense.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsGenerating extends ReportsState {
  const ReportsGenerating();
}

class ReportsGenerated extends ReportsState {
  final String reportType;
  final List<Expense> data;
  final double totalAmount;
  final int itemCount;

  const ReportsGenerated({
    required this.reportType,
    required this.data,
    required this.totalAmount,
    required this.itemCount,
  });

  @override
  List<Object> get props => [reportType, data, totalAmount, itemCount];
}

class ReportsExported extends ReportsState {
  final String filePath;
  final String format;

  const ReportsExported({required this.filePath, required this.format});

  @override
  List<Object> get props => [filePath, format];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object> get props => [message];
}
