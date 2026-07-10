import 'package:injectable/injectable.dart';

import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {
    return [];
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    return category;
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {}
}
