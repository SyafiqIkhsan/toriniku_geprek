import 'package:toriniku_geprek/models/menu_item.dart';
import 'package:toriniku_geprek/repositories/menu_repository.dart';

class MenuService {
  final MenuRepository _repository;

  MenuService({MenuRepository? repository})
      : _repository = repository ?? MenuRepository();

  Future<List<MenuItem>> getAllMenuItems() => _repository.getAll();

  Future<List<MenuItem>> getMenuItemsByCategory(int categoryId) =>
      _repository.getByCategory(categoryId);

  Future<MenuItem?> getMenuItemById(int id) => _repository.getById(id);

  Future<MenuItem> addMenuItem({
    required String name,
    String? description,
    required int categoryId,
    required double price,
  }) async {
    _validateMenuItem(name: name, price: price);
    final item = MenuItem(
      name: name.trim(),
      description: description?.trim(),
      categoryId: categoryId,
      price: price,
    );
    final id = await _repository.insert(item);
    // Fetch the full item (with category) from the DB.
    return (await _repository.getById(id))!;
  }

  Future<void> updateMenuItem(MenuItem item) async {
    if (item.id == null) {
      throw ArgumentError('Cannot update a menu item without an id.');
    }
    _validateMenuItem(name: item.name, price: item.price);
    await _repository.update(
      item.copyWith(
        name: item.name.trim(),
        description: item.description?.trim(),
      ),
    );
  }

  Future<void> deleteMenuItem(int id) => _repository.delete(id);

  // ─── Validation ───────────────────────────────────────────────────────────
  void _validateMenuItem({required String name, required double price}) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Menu item name cannot be empty.');
    }
    if (price < 0) {
      throw ArgumentError('Price cannot be negative.');
    }
  }
}
