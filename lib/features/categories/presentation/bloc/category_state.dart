import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> businessCategories;
  final List<Category> personalCategories;

  const CategoryLoaded({
    required this.businessCategories,
    required this.personalCategories,
  });

  List<Category> get allCategories => [...businessCategories, ...personalCategories];

  @override
  List<Object> get props => [businessCategories, personalCategories];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
  @override
  List<Object> get props => [message];
}
