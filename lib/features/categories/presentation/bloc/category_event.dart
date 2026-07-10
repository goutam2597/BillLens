import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final String name;
  final String type;
  final String icon;
  final String color;

  const AddCategory({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  List<Object> get props => [name, type, icon, color];
}

class UpdateCategory extends CategoryEvent {
  final CategoryData data;

  const UpdateCategory(this.data);

  @override
  List<Object> get props => [data];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object> get props => [id];
}

class CategoryData extends Equatable {
  final String id;
  final String name;
  final String type;
  final String icon;
  final String color;

  const CategoryData({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  @override
  List<Object> get props => [id, name, type, icon, color];
}
