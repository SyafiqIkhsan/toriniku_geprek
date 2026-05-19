import 'package:toriniku_geprek/models/category.dart';
import 'package:toriniku_geprek/repositories/category_repository.dart';

class CategoryService {
  final CategoryRepository _repository;

  CategoryService({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  Future<List<Category>> getAllCategories() => _repository.getAll();

  Future<Category?> getCategoryById(int id) => _repository.getById(id);

  Future<Category> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }
    final id = await _repository.insert(Category(name: trimmed));
    return Category(id: id, name: trimmed);
  }

  Future<void> updateCategory(Category category) async {
    if (category.id == null) {
      throw ArgumentError('Cannot update a category without an id.');
    }
    final trimmed = category.name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }
    await _repository.update(category.copyWith(name: trimmed));
  }

  Future<void> deleteCategory(int id) async {
    // Note: the DB enforces ON DELETE RESTRICT on menu_items.category_id,
    // so this will throw a DatabaseException if any menu items reference it.
    await _repository.delete(id);
  }
}
