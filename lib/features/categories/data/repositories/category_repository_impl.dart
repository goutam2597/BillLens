import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await localDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getBusinessCategories() async {
    try {
      final categories = await localDataSource.getBusinessCategories();
      return Right(categories);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getPersonalCategories() async {
    try {
      final categories = await localDataSource.getPersonalCategories();
      return Right(categories);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> addCategory(Category category) async {
    try {
      var model = CategoryModel.fromEntity(category);
      model = await localDataSource.addCategory(model);
      try {
        final synced = await remoteDataSource.createCategory(model);
        await localDataSource.updateCategory(synced);
        return Right(synced);
      } catch (_) {
        return Right(model);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      var model = CategoryModel.fromEntity(category);
      model = await localDataSource.updateCategory(model);
      try {
        final synced = await remoteDataSource.updateCategory(model);
        await localDataSource.updateCategory(synced);
        return Right(synced);
      } catch (_) {
        return Right(model);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
      try {
        await remoteDataSource.deleteCategory(id);
      } catch (_) {}
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
