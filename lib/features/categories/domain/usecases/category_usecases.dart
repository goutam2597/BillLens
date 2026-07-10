import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final CategoryRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}

class AddCategoryParams extends Equatable {
  final String name;
  final String type;
  final String icon;
  final String color;

  const AddCategoryParams({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  List<Object> get props => [name, type, icon, color];
}

@lazySingleton
class AddCategoryUseCase implements UseCase<Category, AddCategoryParams> {
  final CategoryRepository repository;
  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(AddCategoryParams params) async {
    final category = Category(
      id: '',
      userId: '',
      name: params.name,
      type: params.type,
      icon: params.icon,
      color: params.color,
      syncStatus: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await repository.addCategory(category);
  }
}

@lazySingleton
class UpdateCategoryUseCase implements UseCase<Category, Category> {
  final CategoryRepository repository;
  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Category>> call(Category category) async {
    return await repository.updateCategory(category);
  }
}

class DeleteCategoryParams extends Equatable {
  final String id;
  const DeleteCategoryParams(this.id);

  @override
  List<Object> get props => [id];
}

@lazySingleton
class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final CategoryRepository repository;
  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) async {
    return await repository.deleteCategory(params.id);
  }
}
