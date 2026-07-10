import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/category_usecases.dart';
import 'category_event.dart';
import 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  CategoryBloc({
    required GetCategoriesUseCase getCategoriesUseCase,
    required AddCategoryUseCase addCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _addCategoryUseCase = addCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase,
        super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final businessResult = await _getCategoriesUseCase(const NoParams());
    businessResult.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) {
        final business = categories.where((c) => c.type == 'business').toList();
        final personal = categories.where((c) => c.type == 'personal').toList();
        emit(CategoryLoaded(
          businessCategories: business,
          personalCategories: personal,
        ));
      },
    );
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await _addCategoryUseCase(
      AddCategoryParams(
        name: event.name,
        type: event.type,
        icon: event.icon,
        color: event.color,
      ),
    );
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories()),
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is CategoryLoaded) {
      final existing = currentState.allCategories.firstWhere(
        (c) => c.id == event.data.id,
      );
      final updated = existing.copyWith(
        name: event.data.name,
        type: event.data.type,
        icon: event.data.icon,
        color: event.data.color,
      );
      final result = await _updateCategoryUseCase(updated);
      result.fold(
        (failure) => emit(CategoryError(failure.message)),
        (_) => add(LoadCategories()),
      );
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await _deleteCategoryUseCase(DeleteCategoryParams(event.id));
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories()),
    );
  }
}
