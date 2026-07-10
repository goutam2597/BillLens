import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../expenses/domain/repositories/expense_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

@injectable
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ExpenseRepository _expenseRepository;

  ReportsBloc({required ExpenseRepository expenseRepository})
      : _expenseRepository = expenseRepository,
        super(const ReportsInitial()) {
    on<GenerateReport>(_onGenerateReport);
    on<ExportPdfReport>(_onExportPdf);
    on<ExportCsvReport>(_onExportCsv);
  }

  Future<void> _onGenerateReport(
    GenerateReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsGenerating());
    final result = await _expenseRepository.getExpenses();
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (expenses) {
        var filtered = expenses;
        if (event.startDate != null && event.endDate != null) {
          filtered = expenses.where((e) =>
              e.date.isAfter(event.startDate!.subtract(const Duration(days: 1))) &&
              e.date.isBefore(event.endDate!.add(const Duration(days: 1)))).toList();
        }

        final total = filtered.fold<double>(0, (s, e) => s + e.amount);
        emit(ReportsGenerated(
          reportType: event.reportType,
          data: filtered,
          totalAmount: total,
          itemCount: filtered.length,
        ));
      },
    );
  }

  Future<void> _onExportPdf(
    ExportPdfReport event,
    Emitter<ReportsState> emit,
  ) async {
    if (state is ReportsGenerated) {
      emit(const ReportsExported(
        filePath: '/documents/report.pdf',
        format: 'PDF',
      ));
    }
  }

  Future<void> _onExportCsv(
    ExportCsvReport event,
    Emitter<ReportsState> emit,
  ) async {
    if (state is ReportsGenerated) {
      emit(const ReportsExported(
        filePath: '/documents/report.csv',
        format: 'CSV',
      ));
    }
  }
}
