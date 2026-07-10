import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getBusinessCategories();
  Future<List<CategoryModel>> getPersonalCategories();
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

@LazySingleton(as: CategoryLocalDataSource)
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase _db;

  CategoryLocalDataSourceImpl({required AppDatabase database}) : _db = database;

  CategoriesCompanion _toCompanion(CategoryModel model) {
    return CategoriesCompanion(
      localId: Value(model.id),
      serverId: Value(model.serverId),
      userId: const Value(0),
      name: Value(model.name),
      type: Value(model.type),
      icon: Value(model.icon),
      color: Value(model.color),
      syncStatus: Value(model.syncStatus),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  CategoryModel _fromData(Category data) {
    return CategoryModel(
      id: data.localId ?? '',
      serverId: data.serverId,
      userId: '',
      name: data.name,
      type: data.type,
      icon: data.icon ?? '',
      color: data.color ?? '#2563EB',
      syncStatus: data.syncStatus,
      createdAt: data.createdAt ?? DateTime.now(),
      updatedAt: data.updatedAt ?? DateTime.now(),
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final query = _db.select(_db.categories)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    return rows.map(_fromData).toList();
  }

  @override
  Future<List<CategoryModel>> getBusinessCategories() async {
    final query = _db.select(_db.categories)
      ..where((tbl) => tbl.type.equals('business'))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    return rows.map(_fromData).toList();
  }

  @override
  Future<List<CategoryModel>> getPersonalCategories() async {
    final query = _db.select(_db.categories)
      ..where((tbl) => tbl.type.equals('personal'))
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    return rows.map(_fromData).toList();
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final now = DateTime.now();
    final id = category.id.isEmpty ? const Uuid().v4() : category.id;
    final model = category.copyWithModel(
      id: id,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
    await _db.into(_db.categories).insert(_toCompanion(model));
    return model;
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final model = category.copyWithModel(
      updatedAt: DateTime.now(),
      syncStatus: 'pending',
    );
    await _db.update(_db.categories).replace(_toCompanion(model));
    return model;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final query = _db.delete(_db.categories)
      ..where((tbl) => tbl.localId.equals(id));
    await query.go();
  }
}
