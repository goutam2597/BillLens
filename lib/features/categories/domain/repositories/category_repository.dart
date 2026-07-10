import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Category>>> getBusinessCategories();
  Future<Either<Failure, List<Category>>> getPersonalCategories();
  Future<Either<Failure, Category>> addCategory(Category category);
  Future<Either<Failure, Category>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(String id);
}
