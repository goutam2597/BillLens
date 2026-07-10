import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel?> getExpenseById(String id);
  Future<ExpenseModel?> getExpenseByServerId(String serverId);
  Future<List<ExpenseModel>> searchExpenses(String query);
  Future<ExpenseModel> createExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<void> hardDeleteExpense(String id);
}

@LazySingleton(as: ExpenseLocalDataSource)
class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final AppDatabase _db;

  ExpenseLocalDataSourceImpl({required AppDatabase database})
      : _db = database;

  ExpensesCompanion _toCompanion(ExpenseModel model) {
    return ExpensesCompanion(
      localId: Value(model.id),
      serverId: Value(model.serverId),
      userId: const Value(0),
      vendor: Value(model.vendor),
      amount: Value(model.amount),
      currency: Value(model.currency),
      categoryId: const Value(null),
      categoryName: Value(model.categoryName),
      categoryIcon: Value(model.categoryIcon),
      date: Value(model.date),
      paymentMethod: Value(model.paymentMethod),
      clientName: Value(model.clientName),
      projectName: Value(model.projectName),
      notes: Value(model.notes),
      receiptImageLocalPath: Value(model.receiptImageLocalPath),
      receiptImageRemoteUrl: Value(model.receiptImageRemoteUrl),
      aiConfidence: Value(model.aiConfidence),
      aiExplanation: Value(model.aiExplanation),
      syncStatus: Value(model.syncStatus),
      isDeleted: Value(model.isDeleted),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  ExpenseModel _fromData(Expense data) {
    return ExpenseModel(
      id: data.localId ?? '',
      serverId: data.serverId,
      userId: '',
      vendor: data.vendor,
      amount: data.amount,
      currency: data.currency,
      categoryId: data.categoryId?.toString(),
      categoryName: data.categoryName,
      categoryIcon: data.categoryIcon,
      date: data.date,
      paymentMethod: data.paymentMethod,
      clientName: data.clientName,
      projectName: data.projectName,
      notes: data.notes,
      receiptImageLocalPath: data.receiptImageLocalPath,
      receiptImageRemoteUrl: data.receiptImageRemoteUrl,
      aiConfidence: data.aiConfidence,
      aiExplanation: data.aiExplanation,
      syncStatus: data.syncStatus,
      isDeleted: data.isDeleted,
      createdAt: data.createdAt ?? DateTime.now(),
      updatedAt: data.updatedAt ?? DateTime.now(),
    );
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final query = _db.select(_db.expenses)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final rows = await query.get();
    return rows.map(_fromData).toList();
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    final query = _db.select(_db.expenses)
      ..where((tbl) => tbl.localId.equals(id) & tbl.isDeleted.equals(false))
      ..limit(1);
    final rows = await query.get();
    return rows.isNotEmpty ? _fromData(rows.first) : null;
  }

  @override
  Future<ExpenseModel?> getExpenseByServerId(String serverId) async {
    final query = _db.select(_db.expenses)
      ..where((tbl) => tbl.serverId.equals(serverId) & tbl.isDeleted.equals(false))
      ..limit(1);
    final rows = await query.get();
    return rows.isNotEmpty ? _fromData(rows.first) : null;
  }

  @override
  Future<List<ExpenseModel>> searchExpenses(String query) async {
    final term = '%$query%';
    final dbQuery = _db.select(_db.expenses)
      ..where(
        (tbl) =>
            tbl.isDeleted.equals(false) &
            (tbl.vendor.like(term) | tbl.notes.like(term)),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    final rows = await dbQuery.get();
    return rows.map(_fromData).toList();
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    final now = DateTime.now();
    final id = expense.id.isEmpty ? const Uuid().v4() : expense.id;
    final model = expense.copyWithModel(
      id: id,
      createdAt: expense.createdAt.isAfter(now) ? expense.createdAt : now,
      updatedAt: now,
      syncStatus: expense.syncStatus.isNotEmpty ? expense.syncStatus : 'pending',
    );
    await _db.into(_db.expenses).insert(_toCompanion(model));
    return model;
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    final now = DateTime.now();
    final model = expense.copyWithModel(
      updatedAt: now,
      syncStatus: expense.syncStatus.isNotEmpty ? expense.syncStatus : 'pending',
    );
    await (_db.update(_db.expenses)..where((tbl) => tbl.localId.equals(model.id)))
        .write(_toCompanion(model));
    return model;
  }

  @override
  Future<void> deleteExpense(String id) async {
    final existing = await getExpenseById(id);
    if (existing == null) return;
    final now = DateTime.now();
    final deleted = existing.copyWithModel(
      isDeleted: true,
      syncStatus: 'pending',
      updatedAt: now,
    );
    await (_db.update(_db.expenses)..where((tbl) => tbl.localId.equals(id)))
        .write(_toCompanion(deleted));
  }

  @override
  Future<void> hardDeleteExpense(String id) async {
    await (_db.delete(_db.expenses)..where((tbl) => tbl.localId.equals(id))).go();
  }
}
